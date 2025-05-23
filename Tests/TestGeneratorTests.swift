import XCTest

@testable import Core

final class TestGeneratorTests: XCTestCase {
  var tempDir: URL!
  var outputDir: URL!

  override func setUpWithError() throws {
    tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    outputDir = tempDir.appendingPathComponent("Tests/MyAppTests")
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
  }

  override func tearDownWithError() throws {
    try? FileManager.default.removeItem(at: tempDir)
  }

  func testTestFilesGenerationForMultipleParsedTypes() throws {
    let targetName = "MyApp"

    // Prepare dummy ParsedType(s)
    let dummyFunction = ParsedFunction(
      name: "loadData", isAsync: true, isThrowing: false, parameters: ["param1", "param2"],
      returnType: "String")
    let dummyFunction2 = ParsedFunction(
      name: "saveData", isAsync: false, isThrowing: true, parameters: [], returnType: "String")

    let parsedType1 = ParsedType(typeName: "UserManager", functions: [dummyFunction])
    let parsedType2 = ParsedType(typeName: "DataService", functions: [dummyFunction2])

    // Use the pre-created directory path
    TestGenerator.generate(
      for: [parsedType1, parsedType2], target: targetName, outputPath: outputDir.path)

    // Verify file for UserManagerTests.swift
    let userManagerTestFile = outputDir.appendingPathComponent("UserManagerTests.swift")
    XCTAssertTrue(FileManager.default.fileExists(atPath: userManagerTestFile.path))
    let userManagerContent = try String(contentsOf: userManagerTestFile)
    XCTAssertTrue(userManagerContent.contains("final class UserManagerTests: XCTestCase"))
    XCTAssertTrue(userManagerContent.contains("var sut: UserManager!"))
    XCTAssertTrue(userManagerContent.contains("func testLoadData() async"))

    // Verify file for DataServiceTests.swift
    let dataServiceTestFile = outputDir.appendingPathComponent("DataServiceTests.swift")
    XCTAssertTrue(FileManager.default.fileExists(atPath: dataServiceTestFile.path))
    let dataServiceContent = try String(contentsOf: dataServiceTestFile)
    XCTAssertTrue(dataServiceContent.contains("final class DataServiceTests: XCTestCase"))
    XCTAssertTrue(dataServiceContent.contains("var sut: DataService!"))
    XCTAssertTrue(dataServiceContent.contains("func testSaveData() throws"))

  }
}
