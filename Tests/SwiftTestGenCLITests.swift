import Core
import XCTest

@testable import SwiftTestGenCLI

final class SwiftTestGenCLITests: XCTestCase {
  // These URLs represent a controlled test environment created in a temporary directory.
  // This isolation ensures the CLI tool can be tested without affecting real project files.
  var tempDir: URL!
  var sourceDir: URL!
  var testsDir: URL!

  override func setUpWithError() throws {
    // We use a unique temp directory per test run to avoid cross-test pollution
    // and ensure a clean slate for validating file generation logic.
    tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    // Simulate a realistic Swift Package layout: Sources/MyModule
    // This matches what a developer would pass into the CLI, making the test representative.
    sourceDir = tempDir.appendingPathComponent("Sources/MyModule")
    try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)

    // Directory where generated tests will be placed — again, isolated to avoid side effects.
    testsDir = tempDir.appendingPathComponent("Tests")

    // Add minimal Swift source files to mimic user-written code,
    // allowing us to validate if test files are generated accordingly.
    let dummyFiles = [
      (
        "User.swift",
        """
        class User {
            var id: Int
            var name: String

            init(id: Int, name: String) {
                self.id = id
                self.name = name
            }

            func displayName() -> String {
                return "User: \\(name)"
            }
        }
        """
      ),
      (
        "Product.swift",
        """
        struct Product {
            let id: Int
            let title: String
            var isAvailable: Bool

            func description() -> String {
                return "\\(title) [\\(isAvailable ? "In Stock" : "Out of Stock")]"
            }
        }
        """
      ),
    ]

    for (filename, content) in dummyFiles {
      let fileURL = sourceDir.appendingPathComponent(filename)
      try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
  }

  override func tearDownWithError() throws {
    // Always clean up temp files after each test to keep the environment isolated and clean.
    // Prevents clutter and ensures a fresh test setup next time.
    try? FileManager.default.removeItem(at: tempDir)
  }

  func testCLIGeneratesTestFilesPerSourceFile() async throws {
    // Simulate how a user would invoke the CLI tool from the terminal,
    // providing target, source, and output directories.
    // This helps validate end-to-end integration of the CLI parsing and execution logic.
    let arguments = [
      "MyModule",
      "--source", sourceDir.path,
      "--output", testsDir.path,
    ]

    let cli = try SwiftTestGenCLI.parse(arguments)
    try await cli.run()  // Executes the test generation logic, simulating actual CLI usage

    // These are the expected outputs based on the dummy source files above.
    // We assert both file existence and contents to ensure the generation logic is complete and correct.
    let expectedFiles = [
      ("UserTests.swift", "User"),
      ("ProductTests.swift", "Product"),
    ]

    for (fileName, originalTypeName) in expectedFiles {
      let filePath = testsDir.appendingPathComponent(fileName).path

      // Ensure that each expected test file was actually created
      XCTAssertTrue(
        FileManager.default.fileExists(atPath: filePath),
        "Expected test file \(fileName) does not exist")

      let content = try String(contentsOfFile: filePath)

      // Check that the generated file includes expected components:
      // 1. @testable import to access internal symbols
      // 2. final class declaration for test class structure
      // 3. function declration for test class structure
      // 4. A mention of the original type name to tie test to its source
      XCTAssertTrue(
        content.contains("@testable import MyModule"), "\(fileName) missing module import")
      XCTAssertTrue(content.contains("final class"), "\(fileName) missing class declaration")
      XCTAssertTrue(content.contains("func"), "\(fileName) missing function declaration")
      XCTAssertTrue(
        content.contains(originalTypeName), "\(fileName) content does not reference original type")
    }
  }
}
