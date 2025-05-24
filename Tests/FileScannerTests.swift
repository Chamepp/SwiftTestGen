import XCTest

@testable import Core

final class FileScannerTests: XCTestCase {
  // A temporary directory to simulate a file system environment for testing,
  // ensuring test runs do not affect or depend on real project structure.
  var tempDirectoryURL: URL!

  // Creating an instance of file scanner to test its functionality in tests
  let scanner = FileScanner()

  override func setUpWithError() throws {
    // Generate a unique temporary directory for isolating test files.
    // This prevents interference between tests and ensures clean state.
    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    // Create the temporary directory where test files will be stored.
    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    // The mock structure we are aiming for which represents
    // a real world app strcuture.

    // Sources/MyApp/
    // ├── AppDelegate.swift
    // ├── README.md
    // ├── Home.storyboard
    // └── Features/
    //     ├── HomeViewController.swift
    //     └── Shared/
    //         └── Utils.swift

    // Mapping a structure that represents a real world app structure
    // in order to test the `FileScanner`recursive search functionality
    // by creating nested folders.
    let root = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    let nested1 = root.appendingPathComponent("Features")
    let nested2 = nested1.appendingPathComponent("Shared")

    try FileManager.default.createDirectory(at: nested1, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: nested2, withIntermediateDirectories: true)

    // Define a mix of Swift and non-Swift files to validate file filtering behavior.
    // The purpose is to ensure that only `.swift` files are detected by the scanner.
    let files = [
      root.appendingPathComponent("AppDelegate.swift"),
      root.appendingPathComponent("README.md"),            // Included to verify that non-code files are ignored.
      root.appendingPathComponent("Home.storyboard"),      // Included to simulate a typical Xcode project structure.
      nested1.appendingPathComponent("HomeViewController.swift"),
      nested2.appendingPathComponent("Utils.swift")
    ]

    // Write minimal content into each test file to simulate real Swift source files.
    // The actual content is irrelevant—only the file extension matters for this test.
    for fileURL in files {
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
    let swiftFiles = scanner.swiftFiles(in: path)

    // Expecting exactly 3 Swift files; other file types should be excluded.
    XCTAssertEqual(swiftFiles.count, 3, "Should find only .swift files")

    // Ensure all discovered files indeed have the `.swift` extension.
    XCTAssertTrue(swiftFiles.allSatisfy { $0.hasSuffix(".swift") })
  }
}
