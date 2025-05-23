import XCTest

@testable import Core

final class TestGenVisitorTests: XCTestCase {
  var parser: SwiftFileParser!
  var tempDirectoryURL: URL!

  override func setUpWithError() throws {
    parser = SwiftFileParser()

    tempDirectoryURL = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

    let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    let files = [
      "HomeViewController.swift",  // for class
      "Model.swift",  // for struct
      "Direction.swift",  // for enum
      "Drawable.swift",  // for protocol
    ]

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
              case north
              case south
              case east
              case west

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
        try "print(\"Hello\")".write(to: fileURL, atomically: true, encoding: .utf8)
      }
    }
  }

  override func tearDownWithError() throws {
    parser = nil
    try FileManager.default.removeItem(at: tempDirectoryURL)
  }

  func testParseSpecificFile() throws {
    let filePath =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/HomeViewController.swift").path

    let parsedTypes = try parser.parseFile(at: filePath)

    XCTAssertEqual(parsedTypes.count, 1, "UNABLE TO PARSE DATA")
    XCTAssertEqual(parsedTypes[0].typeName, "HomeViewController", "WRONG TYPE NAME")
    XCTAssertEqual(parsedTypes[0].functions.count, 2, "WRONG FUNCTIONS COUNT")
    XCTAssertEqual(
      parsedTypes[0].functions.map(\.name), ["setupUI", "fetchData"], "FUNCTIONS NAMES NOT MATCHING"
    )
    XCTAssertFalse(parsedTypes[0].functions[0].isAsync, "FUNCTION ONE ASYNC RECOGNITION FAILED")
    XCTAssertTrue(parsedTypes[0].functions[1].isAsync, "FUNCTION TWO ASYNC RECOGNITION FAILED")
    XCTAssertTrue(parsedTypes[0].functions[1].isThrowing, "FUNCTION THROWING RECOGNITION FAILED")
    XCTAssertEqual(
      parsedTypes[0].functions[1].returnType, "String", "FUNCTION TYPE RECOGNITION FAILED")
  }

  func testParseStruct() throws {
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
    let fileURL =
      tempDirectoryURL
      .appendingPathComponent("Sources/MyApp/Drawable.swift")

    let parsedTypes = try parser.parseFile(at: fileURL.path)

    XCTAssertEqual(parsedTypes.count, 1)
    XCTAssertEqual(parsedTypes[0].typeName, "Drawable")
    XCTAssertEqual(parsedTypes[0].functions.map(\.name), ["draw", "resize"])
  }
}
