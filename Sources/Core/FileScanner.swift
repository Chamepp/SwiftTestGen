import Foundation

public class FileScanner {
  public init() {}
  
  public func swiftFiles(in path: String) -> [String] {
    let fm = FileManager.default
    guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
      return []
    }

    return
      contents
      .filter { $0.hasSuffix(".swift") }
      .map { "\(path)/\($0)" }
  }
}
