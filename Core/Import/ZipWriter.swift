import Foundation

enum ZipWriter {
    static func archive(entries: [String: Data]) throws -> Data {
        var locals = Data()
        var centrals = Data()
        let sorted = entries.sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }

        for (name, payload) in sorted {
            let nameData = Data(name.utf8)
            let crc = CRC32.checksum(of: payload)
            let size = UInt32(payload.count)
            let localOffset = UInt32(locals.count)

            locals.appendUInt32(0x0403_4b50)
            locals.appendUInt16(20)
            locals.appendUInt16(0)
            locals.appendUInt16(0)
            locals.appendUInt16(0)
            locals.appendUInt16(0)
            locals.appendUInt32(crc)
            locals.appendUInt32(size)
            locals.appendUInt32(size)
            locals.appendUInt16(UInt16(nameData.count))
            locals.appendUInt16(0)
            locals.append(nameData)
            locals.append(payload)

            centrals.appendUInt32(0x0201_4b50)
            centrals.appendUInt16(20)
            centrals.appendUInt16(20)
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt32(crc)
            centrals.appendUInt32(size)
            centrals.appendUInt32(size)
            centrals.appendUInt16(UInt16(nameData.count))
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt16(0)
            centrals.appendUInt32(0)
            centrals.appendUInt32(localOffset)
            centrals.append(nameData)
        }

        var archive = locals
        let centralOffset = UInt32(archive.count)
        archive.append(centrals)
        archive.appendUInt32(0x0605_4b50)
        archive.appendUInt16(0)
        archive.appendUInt16(0)
        archive.appendUInt16(UInt16(sorted.count))
        archive.appendUInt16(UInt16(sorted.count))
        archive.appendUInt32(UInt32(centrals.count))
        archive.appendUInt32(centralOffset)
        archive.appendUInt16(0)
        return archive
    }
}

private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var little = value.littleEndian
        append(Data(bytes: &little, count: MemoryLayout<UInt16>.size))
    }

    mutating func appendUInt32(_ value: UInt32) {
        var little = value.littleEndian
        append(Data(bytes: &little, count: MemoryLayout<UInt32>.size))
    }
}
