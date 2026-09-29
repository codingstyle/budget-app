import Foundation

extension Data {
    func uInt16(at offset: Int) -> UInt16 {
        subdata(in: offset..<(offset + 2)).withUnsafeBytes { $0.loadUnaligned(as: UInt16.self) }
    }

    func uInt32(at offset: Int) -> UInt32 {
        subdata(in: offset..<(offset + 4)).withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
    }

    func int32(at offset: Int) -> Int32 {
        subdata(in: offset..<(offset + 4)).withUnsafeBytes { $0.loadUnaligned(as: Int32.self) }
    }

    func double(at offset: Int) -> Double {
        subdata(in: offset..<(offset + 8)).withUnsafeBytes { $0.loadUnaligned(as: Double.self) }
    }
}
