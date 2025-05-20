import XCTest
@testable import SwiftTestGenCLI
import Core

final class SwiftTestGenCLITests: XCTestCase {
    var tempDir: URL!
    var sourceDir: URL!
    var outputFile: URL!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        sourceDir = tempDir.appendingPathComponent("Sources/")
        outputFile = tempDir.appendingPathComponent("Tests/MyModuleTests/GeneratedTests.swift")

        try FileManager.default.createDirectory(at: sourceDir, withIntermediateDirectories: true)

        // Add a dummy Swift file in source dir
        let dummyFile = sourceDir.appendingPathComponent("Sample.swift")
        try "class Sample {}".write(to: dummyFile, atomically: true, encoding: .utf8)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

  func testCLIGeneratesTestFile() throws {
      let arguments = [
          "MyModule",
          "--source", sourceDir.path,
          "--output", outputFile.path
      ]

      let cli = try SwiftTestGenCLI.parse(arguments)
      try cli.run()

      XCTAssertTrue(FileManager.default.fileExists(atPath: outputFile.path), "FILE DOES NOT EXIST")

      let content = try String(contentsOf: outputFile)
      XCTAssertTrue(content.contains("@testable import MyModule"), "CONTENT IS MISSING")
      XCTAssertTrue(content.contains("final class GeneratedTests: XCTestCase"), "CONTENT IS MISSING")
  }

}
