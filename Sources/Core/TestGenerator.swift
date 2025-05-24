import Foundation

// TestGenerator is responsible for converting parsed type information into scaffolded test files.
// This helps automate the tedious setup of test cases and ensures consistency across the codebase.
public struct TestGenerator {
  public init() {}

  // This method orchestrates the test generation process.
  // For each parsed type (e.g., a class or struct), it creates a corresponding test class file.
  public func generate(for parsedTypes: [ParsedType], target: String, outputPath: String) {
    for parsedType in parsedTypes {
      let testClassName = "\(parsedType.typeName)Tests"

      // Generates the string representation of the test class using parsed data.
      let testCode = generateTestClass(for: parsedType, target: target)

      let outputDir = URL(fileURLWithPath: outputPath)
      let fileName = "\(testClassName).swift"
      let fileURL = outputDir.appendingPathComponent(fileName)

      do {
        // Ensure the output directory exists to prevent runtime errors during file writing.
        try FileManager.default.createDirectory(
          at: outputDir, withIntermediateDirectories: true, attributes: nil
        )

        // Persist the generated test code into a file.
        // This step completes the automation pipeline from source parsing to test scaffolding.
        try testCode.write(to: fileURL, atomically: true, encoding: .utf8)

      } catch {
        // Handle any errors in a user-visible way to avoid silent failures and aid debugging.
        print("Failed to write file: \(fileName) — Error: \(error)")
      }
    }
  }

  // Generates the code for a full XCTest class based on the parsed type.
  // This includes lifecycle methods and placeholders for each method under test.
  private func generateTestClass(for parsedType: ParsedType, target: String) -> String {
    var code = """
      import XCTest
      @testable import \(target)

      final class \(parsedType.typeName)Tests: XCTestCase {

          var sut: \(parsedType.typeName)!

          override func setUp() {
              super.setUp()
              // System Under Test (sut) is initialized before each test.
              sut = \(parsedType.typeName)()
          }

          override func tearDown() {
              // Clean up to ensure isolation between tests.
              sut = nil
              super.tearDown()
          }

      """

    // For each function in the type, generate a placeholder test function.
    // These are stubs to be completed by AI.
    // The functions bodies will be extracted, sent to ai, and the generated
    // code will be injected in the generated test function templates.
    for function in parsedType.functions {
      code += "\n" + generateTestFunction(for: function)
    }

    code += "\n}\n"

    return code
  }

  // Generates a single test function stub for a method from the parsed type.
  // Incorporates async/throwing behavior and adds TODOs for clarity.
  func generateTestFunction(for function: ParsedFunction) -> String {
    let asyncKeyword = function.isAsync ? "async " : ""
    let throwsKeyword = function.isThrowing ? "throws " : ""

    // Generate a readable test name that matches naming conventions.
    let testName = "test" + function.name.prefix(1).uppercased() + function.name.dropFirst()

    var body = ""
    if function.isAsync {
      body += "        // Await async result\n"
    }
    if function.isThrowing {
      body += "        // Use XCTAssertThrowsError or try\n"
    }
    if !function.parameters.isEmpty {
      // Provide a hint to the AI to populate input values.
      body += "        // TODO: Provide values for parameters: \(function.parameters.joined(separator: ", "))\n"
    }

    // Placeholder for the actual function invocation on the System Under Test.
    body += "        // sut.\(function.name)(...)\n"

    return """
          func \(testName)() \(asyncKeyword)\(throwsKeyword){
      \(body)
          }

      """
  }
}
