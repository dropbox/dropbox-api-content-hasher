import Foundation
import CryptoKit

public struct DropboxContentHasher: HashFunction {
    public typealias Digest = SHA256Digest

    public static var blockByteCount: Int = 4 * 1024 * 1024

    var overallHasher: SHA256
    var blockHasher: SHA256
    var blockPos: Int

    public init() {
        overallHasher = SHA256();
        blockHasher = SHA256();
        blockPos = 0;
    }

    public func finalize() -> SHA256Digest {
        var newFinal = overallHasher
        if blockPos > 0 {
            newFinal.update(data: Data(blockHasher.finalize()))
        }
        return newFinal.finalize()
    }

    public mutating func update(bufferPointer: UnsafeRawBufferPointer)
    {
        var remainingData = bufferPointer.dropFirst(0)
        while !remainingData.isEmpty {
            if self.blockPos == DropboxContentHasher.blockByteCount {
                overallHasher.update(data: Data(blockHasher.finalize()))
                blockHasher = SHA256()
                blockPos = 0
            }

            let spaceInBlock = DropboxContentHasher.blockByteCount - blockPos
            let part = remainingData.prefix(spaceInBlock)

            blockHasher.update(data: part)
            blockPos += part.count

            remainingData = remainingData.dropFirst(spaceInBlock)
        }
    }
}
