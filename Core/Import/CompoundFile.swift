import Foundation

enum CompoundFile {
    private static let endOfChain: UInt32 = 0xFFFFFFFE
    private static let freeSector: UInt32 = 0xFFFFFFFF
    private static let signature = Data([0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1])

    static func matches(_ data: Data) -> Bool {
        data.starts(with: signature)
    }

    static func stream(named name: String, from data: Data) throws -> Data {
        guard matches(data), data.count >= 512 else {
            throw AppError.importFailed("Le fichier Excel OLE est invalide.")
        }

        let sectorShift = data.uInt16(at: 0x1E)
        let miniShift = data.uInt16(at: 0x20)
        let sectorSize = 1 << Int(sectorShift)
        let miniSectorSize = 1 << Int(miniShift)
        let directoryStart = data.uInt32(at: 0x30)
        let miniCutoff = data.uInt32(at: 0x38)
        let miniFATStart = data.uInt32(at: 0x3C)
        let difatStart = data.uInt32(at: 0x44)
        let difatCount = data.uInt32(at: 0x48)

        var fatSectorIndices: [UInt32] = []
        for index in 0..<109 {
            let value = data.uInt32(at: 0x4C + index * 4)
            if value != freeSector {
                fatSectorIndices.append(value)
            }
        }

        var difatSector = difatStart
        var remainingDifat = Int(difatCount)
        while remainingDifat > 0, difatSector < endOfChain {
            let offset = sectorOffset(difatSector, sectorSize: sectorSize)
            guard offset + sectorSize <= data.count else { break }
            let entriesPerSector = sectorSize / 4
            for index in 0..<(entriesPerSector - 1) {
                let value = data.uInt32(at: offset + index * 4)
                if value != freeSector {
                    fatSectorIndices.append(value)
                }
            }
            difatSector = data.uInt32(at: offset + (entriesPerSector - 1) * 4)
            remainingDifat -= 1
        }

        let fat = readFAT(from: data, sectorIndices: fatSectorIndices, sectorSize: sectorSize)
        let directoryData = readChain(
            startingAt: directoryStart,
            fat: fat,
            data: data,
            sectorSize: sectorSize
        )

        var miniFAT: [UInt32] = []
        if miniFATStart < endOfChain {
            let miniFATData = readChain(
                startingAt: miniFATStart,
                fat: fat,
                data: data,
                sectorSize: sectorSize
            )
            for index in stride(from: 0, to: miniFATData.count, by: 4) {
                if index + 4 <= miniFATData.count {
                    miniFAT.append(miniFATData.uInt32(at: index))
                }
            }
        }

        var rootStart: UInt32 = 0
        var rootSize: UInt32 = 0
        var targetStart: UInt32?
        var targetSize: UInt32 = 0

        let entryCount = directoryData.count / 128
        for entryIndex in 0..<entryCount {
            let base = entryIndex * 128
            guard base + 128 <= directoryData.count else { break }
            let nameLength = Int(directoryData.uInt16(at: base + 0x40))
            let type = directoryData[base + 0x42]
            let start = directoryData.uInt32(at: base + 0x74)
            let size = directoryData.uInt32(at: base + 0x78)
            let nameBytes = max(0, nameLength - 2)
            let nameData = directoryData.subdata(in: base..<(base + min(64, nameBytes)))
            let entryName = String(data: nameData, encoding: .utf16LittleEndian) ?? ""

            if type == 5 {
                rootStart = start
                rootSize = size
            }
            if type == 2, entryName.caseInsensitiveCompare(name) == .orderedSame {
                targetStart = start
                targetSize = size
            }
        }

        guard let streamStart = targetStart else {
            throw AppError.importFailed("Flux « \(name) » introuvable dans le fichier Excel.")
        }

        if targetSize < miniCutoff {
            let miniStream = readChain(
                startingAt: rootStart,
                fat: fat,
                data: data,
                sectorSize: sectorSize
            )
            let sliced = Data(miniStream.prefix(Int(rootSize)))
            return readMiniStream(
                startingAt: streamStart,
                size: Int(targetSize),
                miniFAT: miniFAT,
                miniStream: sliced,
                miniSectorSize: miniSectorSize
            )
        }

        let raw = readChain(
            startingAt: streamStart,
            fat: fat,
            data: data,
            sectorSize: sectorSize
        )
        return Data(raw.prefix(Int(targetSize)))
    }

    private static func sectorOffset(_ sector: UInt32, sectorSize: Int) -> Int {
        (Int(sector) + 1) * sectorSize
    }

    private static func readFAT(from data: Data, sectorIndices: [UInt32], sectorSize: Int) -> [UInt32] {
        var fat: [UInt32] = []
        let entriesPerSector = sectorSize / 4
        for sector in sectorIndices {
            let offset = sectorOffset(sector, sectorSize: sectorSize)
            guard offset + sectorSize <= data.count else { continue }
            for index in 0..<entriesPerSector {
                fat.append(data.uInt32(at: offset + index * 4))
            }
        }
        return fat
    }

    private static func readChain(
        startingAt start: UInt32,
        fat: [UInt32],
        data: Data,
        sectorSize: Int
    ) -> Data {
        var result = Data()
        var sector = start
        var seen: Set<UInt32> = []
        while sector < endOfChain, seen.contains(sector) == false {
            seen.insert(sector)
            let offset = sectorOffset(sector, sectorSize: sectorSize)
            if offset + sectorSize <= data.count {
                result.append(data.subdata(in: offset..<(offset + sectorSize)))
            }
            guard Int(sector) < fat.count else { break }
            sector = fat[Int(sector)]
        }
        return result
    }

    private static func readMiniStream(
        startingAt start: UInt32,
        size: Int,
        miniFAT: [UInt32],
        miniStream: Data,
        miniSectorSize: Int
    ) -> Data {
        var result = Data()
        var sector = start
        var seen: Set<UInt32> = []
        while sector < endOfChain, seen.contains(sector) == false, result.count < size {
            seen.insert(sector)
            let offset = Int(sector) * miniSectorSize
            if offset + miniSectorSize <= miniStream.count {
                result.append(miniStream.subdata(in: offset..<(offset + miniSectorSize)))
            }
            guard Int(sector) < miniFAT.count else { break }
            sector = miniFAT[Int(sector)]
        }
        return Data(result.prefix(size))
    }
}
