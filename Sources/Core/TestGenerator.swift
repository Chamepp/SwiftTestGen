import Foundation

// TestGenerator is responsible for converting parsed type information into scaffolded test files.
// This helps automate the tedious setup of test cases and ensures consistency across the codebase.
public struct TestGenerator {

  // Injecting AITestBodyGenerator via dependency injection to promote loose coupling and adhere
  // to the Single Responsibility Principle. This makes the TestGenerator easier to test, extend,
  // and maintain by decoupling it from specific AI generation implementations.
  // The concrete implementation of the generator will be provided externally (in `main.swift`),
  //  allowing for greater flexibility and configurability.
  private let bodyGenerator: AITestBodyGenerator

  public init(bodyGenerator: AITestBodyGenerator) {
    self.bodyGenerator = bodyGenerator
  }

  // This method orchestrates the test generation process.
  // For each parsed type (e.g., a class or struct), it creates a corresponding test class file.
  public func generate(for parsedTypes: [ParsedType], target: String, outputPath: String) async {
    for parsedType in parsedTypes {
      let testClassName = "\(parsedType.typeName)Tests"

      // Generates the string representation of the test class using parsed data.
      let testCode = await generateTestClass(for: parsedType, target: target)

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
  private func generateTestClass(for parsedType: ParsedType, target: String) async -> String {
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

    // For each function in the parsed type, generate a full test method using AI-generated content.
    // The function metadata is passed to the AI test body generator injected earlier in
    // the initializer from `main.swift`, which returns a realistic test implementation.
    // The generated test body is then embedded into the test function template to produce complete,
    // executable test code.
    for function in parsedType.functions {
      let testBody = try? await bodyGenerator.generateBody(for: function, in: parsedType)
      code += "\n" + generateTestFunction(for: function, with: testBody)
    }
    code += "\n}\n"

    return code
  }

  // Generates a complete unit test function for a parsed method.
  // If AI generated test code is available, it embeds it directly with proper formatting.
  // Otherwise, it falls back to a structured placeholder with helpful TODOs to guide manual completion.
  // This ensures that all test stubs are syntactically valid and ready for extension.
  func generateTestFunction(for function: ParsedFunction, with generatedAITest: String?) -> String {
    let asyncKeyword = function.isAsync ? "async " : ""
    let throwsKeyword = function.isThrowing ? "throws " : ""

    // Generate a readable test name that matches naming conventions.
    let testName = "test" + function.name.prefix(1).uppercased() + function.name.dropFirst()

    // If AI provided a body, use it. Otherwise fall back to default stub.
    let body: String
    if let generated = generatedAITest?.trimmingCharacters(in: .whitespacesAndNewlines),
      !generated.isEmpty
    {
      // Indent each line properly (assuming 8 spaces inside func block)
      let indented =
        generated
        .split(separator: "\n")
        .map { "        \($0)" }
        .joined(separator: "\n")
      body = indented
    } else {
      // Fallback placeholder
      var fallback = ""
      fallback += "        // AI TODO\n"

      if function.isAsync {
        fallback += "        // Await async result\n"
      }
      if function.isThrowing {
        fallback += "        // Use XCTAssertThrowsError or try\n"
      }
      if !function.parameters.isEmpty {
        fallback +=
          "        // AI TODO: Provide values for parameters: \(function.parameters.joined(separator: ", "))\n"
      }

      fallback += "        // sut.\(function.name)(...)\n"
      body = fallback
    }

    return """
          func \(testName)() \(asyncKeyword)\(throwsKeyword){
      \(body)
          }

      """
  }
}
