import SwiftSyntax
import XCTest

@testable import Core

final class SwiftFileParserTests: XCTestCase {
  var parser: SwiftFileParser!
  var tempDirectoryURL: URL!

  override func setUpWithError() throws {
    // Instantiate the parser responsible for analyzing Swift source files.
    parser = SwiftFileParser()

    // Create a unique temporary directory to isolate test data from the main environment.
    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    // Create the actual directory structure resembling a typical iOS project.
    // This ensures our test mimics a real-world use case for parser inputs.
    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    // Define a mock Swift file content that includes various function signatures.
    // This ensures the parser is tested against realistic, syntactically valid code.
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

    // Write the Swift file into the mock Sources directory.
    // The parser will later analyze this file.
    let fileURL = sourcesDir.appendingPathComponent("TestService.swift")
    try code.write(to: fileURL, atomically: true, encoding: .utf8)
  }

  override func tearDownWithError() throws {
    // Clean up the temporary directory after each test to ensure isolation and prevent side effects.
    try FileManager.default.removeItem(at: tempDirectoryURL)
  }

  func testVisitorParsesClassAndFunctions() throws {
    // Construct the path to the mock Swift file we wrote earlier.
    let fileURL = tempDirectoryURL.appendingPathComponent("Sources/MyApp/TestService.swift")

    // Sanity check: Ensure the file exists before parsing.
    XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))

    // Parse the Swift file and extract types and their functions.
    let parsedTypes = try parser.parseFile(at: fileURL.path)

    // The mock file includes a single class, so we expect exactly one parsed type.
    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "TestService")

    // We defined four methods in the mock class; ensure all are detected.
    XCTAssertEqual(parsedTypes[0].functions.count, 4)

    // Verify that function names were correctly parsed and match the expected order.
    let names = parsedTypes[0].functions.map(\.name)
    XCTAssertEqual(names, ["syncCall", "asyncCall", "throwingCall", "fullCall"])

    // Detailed property checks to ensure async/throwing modifiers are correctly interpreted.
    XCTAssertFalse(parsedTypes[0].functions[0].isAsync)     // syncCall
    XCTAssertTrue(parsedTypes[0].functions[1].isAsync)       // asyncCall
    XCTAssertTrue(parsedTypes[0].functions[2].isThrowing)    // throwingCall

    // Check the most complex function: async, throwing, with parameters and return type.
    let fullCall = parsedTypes[0].functions[3]
    XCTAssertTrue(fullCall.isAsync)
    XCTAssertTrue(fullCall.isThrowing)
    XCTAssertEqual(fullCall.parameters, ["name: String", "age: Int"])
    XCTAssertEqual(fullCall.returnType, "Bool")
  }
}
