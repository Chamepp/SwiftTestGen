import Core
import XCTest

@testable import SwiftTestGenCLI

final class SwiftTestGenCLITests: XCTestCase {
  var tempDir: URL!
  var sourceDir: URL!
  var testsDir: URL!

  override func setUpWithError() throws {
    tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    sourceDir = tempDir.appendingPathComponent("Sources/MyModule")
    try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)

    testsDir = tempDir.appendingPathComponent("Tests")

    let dummyFiles = [
      ("User.swift", "class User {}"),
      ("Product.swift", "class Product {}"),
    ]

    for (filename, content) in dummyFiles {
      let fileURL = sourceDir.appendingPathComponent(filename)
      try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: tempDir)
  }

  func testCLIGeneratesTestFilesPerSourceFile() throws {
    let arguments = [
      "MyModule",
      "--source", sourceDir.path,
      "--output", testsDir.path,
    ]

    let cli = try SwiftTestGenCLI.parse(arguments)
    try cli.run()

    // Define expected test files
    let expectedFiles = [
      ("UserTests.swift", "User"),
      ("ProductTests.swift", "Product"),
    ]

    for (fileName, originalTypeName) in expectedFiles {
      let filePath = testsDir.appendingPathComponent(fileName).path
      XCTAssertTrue(
        FileManager.default.fileExists(atPath: filePath),
        "Expected test file \(fileName) does not exist")

      let content = try String(contentsOfFile: filePath)
      XCTAssertTrue(
        content.contains("@testable import MyModule"), "\(fileName) missing module import")
      XCTAssertTrue(content.contains("final class"), "\(fileName) missing class declaration")
      XCTAssertTrue(
        content.contains(originalTypeName), "\(fileName) content does not reference original type")
    }
  }
}
