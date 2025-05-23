import SwiftSyntax
import XCTest

@testable import Core

final class SwiftFileParserTests: XCTestCase {
  var parser: SwiftFileParser!
  var tempDirectoryURL: URL!

  override func setUpWithError() throws {
    parser = SwiftFileParser()
    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    let code = """
      class TestService {
          func syncCall() {}
          func asyncCall() async {}
          func throwingCall() throws {}
          func fullCall(name: String, age: Int) async throws -> Bool {
              return true
          }
      }
      """

    let fileURL = sourcesDir.appendingPathComponent("TestService.swift")
    try code.write(to: fileURL, atomically: true, encoding: .utf8)
  }

  override func tearDownWithError() throws {
    try FileManager.default.removeItem(at: tempDirectoryURL)
  }
  func testVisitorParsesClassAndFunctions() throws {
    let fileURL =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/TestService.swift")

    XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

    let parsedTypes = try parser.parseFile(at: fileURL.path)

    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "TestService")
    XCTAssertEqual(parsedTypes[0].functions.count, 4)

    let names = parsedTypes[0].functions.map(\.name)
    XCTAssertEqual(names, ["syncCall", "asyncCall", "throwingCall", "fullCall"])

    XCTAssertFalse(parsedTypes[0].functions[0].isAsync)
    XCTAssertTrue(parsedTypes[0].functions[1].isAsync)
    XCTAssertTrue(parsedTypes[0].functions[2].isThrowing)

    let fullCall = parsedTypes[0].functions[3]
    XCTAssertTrue(fullCall.isAsync)
    XCTAssertTrue(fullCall.isThrowing)
    XCTAssertEqual(fullCall.parameters, ["name: String", "age: Int"])
    XCTAssertEqual(fullCall.returnType, "Bool")
  }

}
