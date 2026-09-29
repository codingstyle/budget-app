import Foundation
import zlib

enum ZipInflate {
    static func inflateRaw(data: Data, uncompressedSize: Int) throws -> Data {
        if uncompressedSize == 0 {
            return Data()
        }

        var output = Data(count: uncompressedSize)
        let status: Int32 = data.withUnsafeBytes { sourceBuffer in
            output.withUnsafeMutableBytes { destinationBuffer in
                guard let source = sourceBuffer.bindMemory(to: Bytef.self).baseAddress,
                      let destination = destinationBuffer.bindMemory(to: Bytef.self).baseAddress else {
                    return Z_DATA_ERROR
                }

                var stream = z_stream()
                stream.next_in = UnsafeMutablePointer(mutating: source)
                stream.avail_in = uInt(data.count)
                stream.next_out = destination
                stream.avail_out = uInt(uncompressedSize)

                let initStatus = inflateInit2_(
                    &stream,
                    -MAX_WBITS,
                    ZLIB_VERSION,
                    Int32(MemoryLayout<z_stream>.size)
                )
                guard initStatus == Z_OK else { return initStatus }

                let inflateStatus = inflate(&stream, Z_FINISH)
                inflateEnd(&stream)
                return inflateStatus
            }
        }

        guard status == Z_STREAM_END || status == Z_OK else {
            throw AppError.importFailed("Impossible de décompresser le fichier Excel.")
        }
        return output
    }
}
