import DropboxContentHasher

import Foundation
import CryptoKit

import Algorithms

@main
public struct TestHash {

    public static func main() {
        // Get args excluding executable name.
        let args = CommandLine.arguments.dropFirst()

        if args.count != 0 {
            print("No arguments expected, got \(args).")
            exit(1)
        }

        let b = DropboxContentHasher.blockByteCount

        let tests: [[Int]] = [
            [0],
            [100],
            [100, 10],
            [b-1],
            [b],
            [b+1],

            [b-2, 1],
            [b-2, 2],
            [b-2, 3],

            [b-2, b+1],
            [b-2, b+2],
            [b-2, b+3],

            [5, 5, 5],
            [5, 5, 5, b],
            [5, 5, 5, 3*b],
            [5, 5, 5, 3*b, 5, 5, 5, 3*b],
        ]

        let longestLength = tests.max(by: {$1.count > $0.count})!.count

        print("generating random data")

        guard let data = try? random(length: longestLength) else {
            print("Error generating random data of length \(longestLength)")
            exit(1)
        }

        for test in tests {
            let passed = check(data: data, chunkSizes: test)
            if !passed {
                exit(2)
            }
        }

        print("all passed")
    }

    static func random(length: Int) throws -> Data {
        return Data((0 ..< length).map { _ in UInt8.random(in: UInt8.min ... UInt8.max) })
    }

    static func referenceHasher(_ data: Data) -> String {
        var overallHasher = SHA256()

        for chunk in data.chunks(ofCount: DropboxContentHasher.blockByteCount) {
            var blockHasher = SHA256()
            blockHasher.update(data: chunk)
            overallHasher.update(data: Data(blockHasher.finalize()))
        }

        let digest = overallHasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func check(data: Data, chunkSizes: [Int]) -> Bool {
        print("Checking \(chunkSizes)")

        var hasher = DropboxContentHasher()

        var input = data
        var totalLength = 0

        for chunkSize in chunkSizes {
            let chunk = input.prefix(chunkSize)
            input = input.dropFirst(chunkSize)
            hasher.update(data: Data(chunk))
            totalLength += chunkSize
        }

        let resultDigest = hasher.finalize()
        let result = resultDigest.map { String(format: "%02x", $0) }.joined()
        let reference = referenceHasher(data.prefix(totalLength))

        let passed = result == reference
        if !passed {
            print("- FAILED: \(reference) \(result)")
        }

        return passed
    }
}
