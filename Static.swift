
import Foundation

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ path: String, encoding: String.Encoding = .utf8) throws {
        FileManager.default.createFile(atPath: path, contents: nil)
        self.fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

try FileManager.default.createDirectory(atPath: "_site", withIntermediateDirectories: true)
var file = try FileHandlerOutputStream("_site/aaa.txt")

for i in 0..<1000 {
    print(i, to: &file)
}
