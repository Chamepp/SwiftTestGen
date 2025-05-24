import Foundation

// FileScanner is responsible for locating relevant Swift source files
// within a given directory. This abstraction keeps file-related logic
// separated from parsing and test generation, aligning with single responsibility principles.
public class FileScanner {

  // A public initializer is exposed so other components
  // (like CLI tools or generators) can instantiate and use this class freely.
  // When this functionality expands, we use this initializer in the future.
  public init() {}

  // This method retrieves all Swift files from the specified directory.
  // We filter by ".swift" to limit processing to only source files,
  // which is crucial for avoiding irrelevant files (e.g., JSON, plist, etc.).
  public func swiftFiles(in path: String) -> [String] {
    let fm = FileManager.default

    // Attempt to read the contents of the directory.
    // If it fails (due to permission issues or non-existent path),
    // we safely return an empty list to avoid crashing the tool.
    guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
      return []
    }

    // We return fully qualified paths to each Swift file
    // to simplify downstream usage (like parsing and code generation).
    // Using full paths ensures tools don't need to resolve relative paths later.
    return contents
      .filter { $0.hasSuffix(".swift") }     // Focus only on Swift source files
      .map { "\(path)/\($0)" }               // Construct full path strings
  }
}
