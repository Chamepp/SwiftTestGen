import Foundation

public struct TestGenerator {

  public static func generate(for parsedTypes: [ParsedType], target: String, outputPath: String) {

    for parsedType in parsedTypes {
      let testClassName = "\(parsedType.typeName)Tests"
      let testCode = generateTestClass(for: parsedType, target: target)

      let fileName = "\(testClassName).swift"
      let fileURL = URL(fileURLWithPath: outputPath).appendingPathComponent(fileName)
      let outputDir = fileURL.deletingLastPathComponent()

      do {
        try FileManager.default.createDirectory(
          at: outputDir, withIntermediateDirectories: true, attributes: nil)

        try testCode.write(to: fileURL, atomically: true, encoding: .utf8)
      } catch {
        print("Failed to write file: \(fileName) — Error: \(error)")
      }
    }
  }

  private static func generateTestClass(for parsedType: ParsedType, target: String) -> String {
    var code = """
      import XCTest
      @testable import \(target)

      final class \(parsedType.typeName)Tests: XCTestCase {

          var sut: \(parsedType.typeName)!

          override func setUp() {
              super.setUp()
              sut = \(parsedType.typeName)()
          }

          override func tearDown() {
              sut = nil
              super.tearDown()
          }

      """

    for function in parsedType.functions {
      code += "\n" + generateTestFunction(for: function)
    }

    code += "\n}\n"
    return code
  }

  private static func generateTestFunction(for function: ParsedFunction) -> String {
    let asyncKeyword = function.isAsync ? "async " : ""
    let throwsKeyword = function.isThrowing ? "throws " : ""

    let testName = "test" + function.name.prefix(1).uppercased() + function.name.dropFirst()

    var body = ""
    if function.isAsync {
      body += "        // Await async result\n"
    }
    if function.isThrowing {
      body += "        // Use XCTAssertThrowsError or try\n"
    }
    if !function.parameters.isEmpty {
      body +=
        "        // TODO: Provide values for parameters: \(function.parameters.joined(separator: ", "))\n"
    }

    body += "        // sut.\(function.name)(...)\n"

    return """
          func \(testName)() \(asyncKeyword)\(throwsKeyword){
      \(body)
          }

      """
  }
}
