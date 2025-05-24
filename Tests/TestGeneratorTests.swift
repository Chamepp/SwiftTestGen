import XCTest

@testable import Core

final class TestGeneratorTests: XCTestCase {
  // A temporary directory to simulate a file system environment for testing,
  // ensuring test runs do not affect or depend on real project structure.
  var tempDir: URL!
  var outputDir: URL!

  override func setUpWithError() throws {
    // Create a unique temporary directory for this test session.
    // This isolates the test environment and prevents conflicts between test runs.
    tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    // Define where generated test files will be placed.
    // This structure mimics a real-world XCTest folder structure: Tests/<TargetName>Tests
    outputDir = tempDir.appendingPathComponent("Tests/MyAppTests")
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    // Clean up the temporary directory after each test run.
    // This ensures leftover files do not pollute future tests or the local file system.
    try? FileManager.default.removeItem(at: tempDir)
  }

  func testTestFilesGenerationForMultipleParsedTypes() throws {
    let targetName = "MyApp"

    // Simulate parsed Swift types as they would appear after analyzing real source code.
    // These are mock representations that mimic what the actual parser would return.

    // Represents an async function with parameters and a return type.
    let dummyFunction = ParsedFunction(
      name: "loadData", isAsync: true, isThrowing: false, parameters: ["param1", "param2"],
      returnType: "String")

    // Represents a throwing function with no parameters and a return type.
    let dummyFunction2 = ParsedFunction(
      name: "saveData", isAsync: false, isThrowing: true, parameters: [], returnType: "String")

    // These mock types simulate what would be parsed from the app's source code.
    let parsedType1 = ParsedType(typeName: "UserManager", functions: [dummyFunction])
    let parsedType2 = ParsedType(typeName: "DataService", functions: [dummyFunction2])

    // Run the core logic: generate test files from parsed type data
    // This is the main unit under test — we validate if it correctly creates XCTest boilerplate.
    TestGenerator.generate(
      for: [parsedType1, parsedType2], target: targetName, outputPath: outputDir.path)

    // Validate the generated test file for UserManager
    let userManagerTestFile = outputDir.appendingPathComponent("UserManagerTests.swift")

    // Ensure the file was created at the expected path
    XCTAssertTrue(FileManager.default.fileExists(atPath: userManagerTestFile.path))

    // Verify that generated test content includes expected components
    // This ensures naming conventions, test stubs, and type references are correctly applied
    let userManagerContent = try String(contentsOf: userManagerTestFile)
    XCTAssertTrue(userManagerContent.contains("final class UserManagerTests: XCTestCase"))
    XCTAssertTrue(userManagerContent.contains("var sut: UserManager!"))
    XCTAssertTrue(userManagerContent.contains("func testLoadData() async"))

    // Repeat verification for the second type: DataService
    let dataServiceTestFile = outputDir.appendingPathComponent("DataServiceTests.swift")
    XCTAssertTrue(FileManager.default.fileExists(atPath: dataServiceTestFile.path))
    let dataServiceContent = try String(contentsOf: dataServiceTestFile)
    XCTAssertTrue(dataServiceContent.contains("final class DataServiceTests: XCTestCase"))
    XCTAssertTrue(dataServiceContent.contains("var sut: DataService!"))
    XCTAssertTrue(dataServiceContent.contains("func testSaveData() throws"))
  }
}
