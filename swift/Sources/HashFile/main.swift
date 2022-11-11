import Foundation
import DropboxContentHasher

@main
public struct hashFile {
    public static func main() {
        // Get args excluding executable name.
        let args = CommandLine.arguments.dropFirst()

        if args.count != 1 {
            print("Expecting only one argument, got \(args).")
            exit(1)
        }

        let filePath = args.first!

        guard let file = FileHandle(forReadingAtPath: filePath) else {
            print("Failed to read file: \(filePath)")
            exit(1)
        }

        var hasher = DropboxContentHasher()
        do {
            var done = false
            while (!done) {
                try autoreleasepool {
                    guard let data = try file.read(upToCount: 1024) else {
                        done = true
                        return
                    }
                    hasher.update(data: data)
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }

        let digest = hasher.finalize()
        let hexStr = digest.map { String(format: "%02x", $0) }.joined()

        print(hexStr)
    }
}
