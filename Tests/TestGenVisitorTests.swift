import XCTest

@testable import Core

final class TestGenVisitorTests: XCTestCase {
  var parser: SwiftFileParser!
  var tempDirectoryURL: URL!

  override func setUpWithError() throws {
    // Initialize the parser before each test; this isolates test logic and avoids reuse side-effects.
    parser = SwiftFileParser()

    // Create a temporary directory with a unique identifier to ensure test isolation and prevent file conflicts.
    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    // Make sure the temp directory exists before writing any test files into it.
    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    // Simulate a typical Swift project structure for tests to mimic a real-world environment.
    let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    // Define a variety of Swift source files to verify the parser's ability to handle different declarations.
    let files = [
      "HomeViewController.swift",  // class
      "Model.swift",               // struct
      "Direction.swift",           // enum
      "Drawable.swift",            // protocol
    ]

    // Write minimal but representative Swift code into each file to trigger specific parsing behaviors.
    for file in files {
      let fileURL = sourcesDir.appendingPathComponent(file)

      switch file {
      case "HomeViewController.swift":
        let code = """
          class HomeViewController {
              func setupUI() {}
              func fetchData() async throws -> String {
                  return "Data"
              }
          }
          """
        try code.write(to: fileURL, atomically: true, encoding: .utf8)

      case "Model.swift":
        let code = """
          struct User {
              let id: Int
              var name: String

              func greet() -> String {
                  return "Hello, \\(name)"
              }
          }
          """
        try code.write(to: fileURL, atomically: true, encoding: .utf8)

      case "Direction.swift":
        let code = """
          enum Direction {
              case north, south, east, west

              func description() -> String {
                  switch self {
                  case .north: return "North"
                  case .south: return "South"
                  case .east: return "East"
                  case .west: return "West"
                  }
              }
          }
          """
        try code.write(to: fileURL, atomically: true, encoding: .utf8)

      case "Drawable.swift":
        let code = """
          protocol Drawable {
              func draw()
              func resize(to size: Int)
          }
          """
        try code.write(to: fileURL, atomically: true, encoding: .utf8)

      default:
        // Fallback to generic content for unexpected file names.
        try "print(\"Hello\")".write(to: fileURL, atomically: true, encoding: .utf8)
      }
    }
  }

  override func tearDownWithError() throws {
    // Clean up to prevent test pollution: remove temp directory and deallocate the parser.
    parser = nil
    try FileManager.default.removeItem(at: tempDirectoryURL)
  }

  func testParseSpecificFile() throws {
    // Focused test: ensures the parser correctly identifies class and async/throwing function traits.
    let filePath =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/HomeViewController.swift").path

    let parsedTypes = try parser.parseFile(at: filePath)

    // Verify one class is parsed and its structure is correctly extracted.
    XCTAssertEqual(parsedTypes.count, 1, "UNABLE TO PARSE DATA")
    XCTAssertEqual(parsedTypes[0].typeName, "HomeViewController", "WRONG TYPE NAME")
    XCTAssertEqual(parsedTypes[0].functions.count, 2, "WRONG FUNCTIONS COUNT")
    XCTAssertEqual(
      parsedTypes[0].functions.map(\.name), ["setupUI", "fetchData"], "FUNCTIONS NAMES NOT MATCHING"
    )

    // Check async and throwing function modifiers to validate proper function metadata extraction.
    XCTAssertFalse(parsedTypes[0].functions[0].isAsync, "FUNCTION ONE ASYNC RECOGNITION FAILED")
    XCTAssertTrue(parsedTypes[0].functions[1].isAsync, "FUNCTION TWO ASYNC RECOGNITION FAILED")
    XCTAssertTrue(parsedTypes[0].functions[1].isThrowing, "FUNCTION THROWING RECOGNITION FAILED")
    XCTAssertEqual(
      parsedTypes[0].functions[1].returnType, "String", "FUNCTION TYPE RECOGNITION FAILED")
  }

  func testParseStruct() throws {
    // Verifies the parser correctly handles `struct` definitions and their methods.
    let fileURL =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/Model.swift")

    let parsedTypes = try parser.parseFile(at: fileURL.path)

    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "User")
    XCTAssertEqual(parsedTypes[0].functions.map(\.name), ["greet"])
    XCTAssertEqual(parsedTypes[0].functions[0].returnType, "String")
  }

  func testParseEnum() throws {
    // Ensures the parser correctly extracts `enum` definitions and methods.
    let fileURL =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/Direction.swift")

    let parsedTypes = try parser.parseFile(at: fileURL.path)

    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "Direction")
    XCTAssertEqual(parsedTypes[0].functions.map(\.name), ["description"])
    XCTAssertEqual(parsedTypes[0].functions[0].returnType, "String")
  }

  func testParseProtocol() throws {
    // Tests that the parser recognizes `protocol` definitions and lists all declared functions.
    let fileURL =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/Drawable.swift")

    let parsedTypes = try parser.parseFile(at: fileURL.path)

    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "Drawable")
    XCTAssertEqual(parsedTypes[0].functions.map(\.name), ["draw", "resize"])
  }
}
