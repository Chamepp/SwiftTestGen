import XCTest

@testable import Core

final class FileScannerTests: XCTestCase {
  var tempDirectoryURL: URL!

  override func setUpWithError() throws {
    // Generate a unique temporary directory for isolating test files.
    // This prevents interference between tests and ensures clean state.
    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    // Create the temporary directory where test files will be stored.
    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    // Define a mix of Swift and non-Swift files to validate file filtering behavior.
    // The purpose is to ensure that only `.swift` files are detected by the scanner.
    let files = [
      "AppDelegate.swift",
      "HomeViewController.swift",
      "Utils.swift",
      "README.md",            // Included to verify that non-code files are ignored.
      "Home.storyboard",      // Included to simulate a typical Xcode project structure.
    ]

    // Create a mock "Sources/MyApp" directory structure to mimic real-world iOS project layout.
    let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    // Write minimal content into each test file to simulate real Swift source files.
    // The actual content is irrelevant—only the file extension matters for this test.
    for file in files {
      let fileURL = sourcesDir.appendingPathComponent(file)
      try "print(\"Hello\")".write(to: fileURL, atomically: true, encoding: .utf8)
    }
  }

  override func tearDownWithError() throws {
    // Clean up after test execution by deleting the temporary directory.
    // This avoids leaving behind residual test data and helps maintain test hygiene.
    try FileManager.default.removeItem(at: tempDirectoryURL)
  }

  func testSwiftFileDiscovery() throws {
    // Get the full path of the mock source directory created in setUp.
    let path = tempDirectoryURL.appendingPathComponent("Sources/MyApp").path

    // Invoke the function under test, which is responsible for locating `.swift` files.
    // This test checks whether only Swift files are discovered from the given directory.
    let swiftFiles = FileScanner.swiftFiles(in: path)

    // Expecting exactly 3 Swift files; other file types should be excluded.
    XCTAssertEqual(swiftFiles.count, 3, "Should find only .swift files")

    // Ensure all discovered files indeed have the `.swift` extension.
    XCTAssertTrue(swiftFiles.allSatisfy { $0.hasSuffix(".swift") })
  }
}
