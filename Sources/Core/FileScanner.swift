import Foundation

// FileScanner is responsible for locating relevant Swift source files
// within a given directory. This abstraction keeps file-related logic
// separated from parsing and test generation, aligning with single responsibility principles.
public class FileScanner {

  // A public initializer is exposed so other components
  // (like CLI tools or generators) can instantiate and use this class freely.
  // When this functionality expands, we use this initializer in the future.
  public init() {}

  // This method retrieves all Swift files from the directory tree(whole project).
  // We filter by ".swift" to limit processing to only source files,
  // which is crucial for avoiding irrelevant files (e.g., JSON, plist, etc.).
  public func swiftFiles(in path: String) -> [String] {
    let fm = FileManager.default
    var swiftFilePaths: [String] = []

    // Attempt to read the contents of directories and searching for `.swift`
    // files by using a recursive enumerator to walk through the file tree.
    // If it fails (due to permission issues or non-existent path),
    // We safely return an empty list to avoid crashing the tool.
    // This error can be handled in the near future with the `SwiftTestGenErrors.swift`
    // alongside other errors.
    guard let enumerator = fm.enumerator(atPath: path) else {
      return []
    }

    for case let file as String in enumerator {
      // Check for .swift extension
      if file.hasSuffix(".swift") {
        let fullPath = (path as NSString).appendingPathComponent(file)
        swiftFilePaths.append(fullPath)
      }
    }

    // We return fully qualified paths to each Swift file
    // to simplify downstream usage (like parsing and code generation).
    // Using full paths ensures tools don't need to resolve relative paths later.
    return swiftFilePaths
  }
}
