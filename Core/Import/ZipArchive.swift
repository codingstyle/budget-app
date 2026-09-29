import Foundation

struct ZipFileEntry: Sendable {
    let name: String
    let compressionMethod: UInt16
    let compressedSize: UInt32
    let uncompressedSize: UInt32
    let localHeaderOffset: UInt32
}

enum ZipArchive {
    static func data(named name: String, in archive: Data) throws -> Data {
        let entries = try entries(in: archive)
        guard let entry = entries.first(where: { $0.name == name }) else {
            throw AppError.importFailed("Fichier manquant dans le classeur : \(name)")
        }
        return try extract(entry, from: archive)
    }

    static func entries(in archive: Data) throws -> [ZipFileEntry] {
        guard let eocd = endOfCentralDirectory(in: archive) else {
            throw AppError.importFailed("Archive Excel invalide.")
        }

        var offset = Int(eocd.centralDirectoryOffset)
        var result: [ZipFileEntry] = []
        for _ in 0..<eocd.entryCount {
            guard offset + 46 <= archive.count else {
                throw AppError.importFailed("Répertoire central ZIP tronqué.")
            }
            let signature = archive.uInt32(at: offset)
            guard signature == 0x02014b50 else {
                throw AppError.importFailed("Signature ZIP inattendue.")
            }

            let compressionMethod = archive.uInt16(at: offset + 10)
            let compressedSize = archive.uInt32(at: offset + 20)
            let uncompressedSize = archive.uInt32(at: offset + 24)
            let nameLength = Int(archive.uInt16(at: offset + 28))
            let extraLength = Int(archive.uInt16(at: offset + 30))
            let commentLength = Int(archive.uInt16(at: offset + 32))
            let localHeaderOffset = archive.uInt32(at: offset + 42)
            let nameStart = offset + 46
            let nameEnd = nameStart + nameLength
            guard nameEnd <= archive.count else {
                throw AppError.importFailed("Nom de fichier ZIP tronqué.")
            }
            let name = String(data: archive.subdata(in: nameStart..<nameEnd), encoding: .utf8) ?? ""
            result.append(
                ZipFileEntry(
                    name: name,
                    compressionMethod: compressionMethod,
                    compressedSize: compressedSize,
                    uncompressedSize: uncompressedSize,
                    localHeaderOffset: localHeaderOffset
                )
            )
            offset = nameEnd + extraLength + commentLength
        }
        return result
    }

    private static func extract(_ entry: ZipFileEntry, from archive: Data) throws -> Data {
        let headerOffset = Int(entry.localHeaderOffset)
        guard headerOffset + 30 <= archive.count else {
            throw AppError.importFailed("En-tête local ZIP tronqué.")
        }
        let nameLength = Int(archive.uInt16(at: headerOffset + 26))
        let extraLength = Int(archive.uInt16(at: headerOffset + 28))
        let dataStart = headerOffset + 30 + nameLength + extraLength
        let dataEnd = dataStart + Int(entry.compressedSize)
        guard dataEnd <= archive.count else {
            throw AppError.importFailed("Données ZIP tronquées.")
        }
        let compressed = archive.subdata(in: dataStart..<dataEnd)
        switch entry.compressionMethod {
        case 0:
            return compressed
        case 8:
            return try ZipInflate.inflateRaw(
                data: compressed,
                uncompressedSize: Int(entry.uncompressedSize)
            )
        default:
            throw AppError.importFailed("Compression ZIP non supportée (\(entry.compressionMethod)).")
        }
    }

    private static func endOfCentralDirectory(in archive: Data) -> (
        entryCount: UInt16,
        centralDirectoryOffset: UInt32
    )? {
        let signature: UInt32 = 0x06054b50
        let minimumEOCD = 22
        guard archive.count >= minimumEOCD else { return nil }
        let maxComment = 65535
        let start = max(0, archive.count - minimumEOCD - maxComment)
        var index = archive.count - minimumEOCD
        while index >= start {
            if archive.uInt32(at: index) == signature {
                let entryCount = archive.uInt16(at: index + 10)
                let offset = archive.uInt32(at: index + 16)
                return (entryCount, offset)
            }
            index -= 1
        }
        return nil
    }
}
