import XCTest
@testable import Core

final class TestGeneratorTests: XCTestCase {
    var tempDir: URL!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testTestFileGeneration() throws {
        let targetName = "MyApp"
        let outputPath = tempDir.appendingPathComponent("GeneratedTests.swift").path

        // Generate the test file
        TestGenerator.generate(for: targetName, outputPath: outputPath)

        // Read generated content
        let fileContent = try String(contentsOfFile: outputPath)

        // Assert content
        XCTAssertTrue(fileContent.contains("import XCTest"))
        XCTAssertTrue(fileContent.contains("@testable import \(targetName)"))
        XCTAssertTrue(fileContent.contains("final class GeneratedTests: XCTestCase"))
        XCTAssertTrue(fileContent.contains("func testExample()"))
    }
}
