import Foundation

// AITestBodyGenerator is responsible for generating AI-powered test bodies
// for Swift functions using XCTest style. By offloading test logic generation
// to an AI model, we automate the creation of meaningful, contextual test code,
// reducing boilerplate and accelerating developer productivity. This will be injected
// into `TestGenerator.swift` from the cli, `main.swift`
public struct AITestBodyGenerator {

  // Initializes the generator. Stateless by design for now for simplicity
  // of usage in the cli. This will be updated later.
  public init() {}

  // Generates a test body for a specific function within a type by crafting a
  // descriptive prompt and delegating the test generation to the AI model.
  // This abstracts away the complexity of writing tests while ensuring relevance to the function's behavior.
  public func generateBody(for function: ParsedFunction, in type: ParsedType) async throws -> String
  {
    let prompt = buildPrompt(for: function, in: type)
    let response = try await OpenAIClient.shared.generate(prompt: prompt)
    return response
  }

  // Constructs a detailed, context-rich prompt tailored to the function and its signature.
  // The prompt guides the AI to produce a clean, idiomatic XCTest body
  // using the arrange-act-assert convention, aligning with Swift testing best practices.
  private func buildPrompt(for function: ParsedFunction, in type: ParsedType) -> String {
    let paramList = function.parameters.joined(separator: ", ")
    return """
      Write a Swift XCTest function for \(type.typeName).\(function.name).
      It is \(function.isAsync ? "an async" : "a") \(function.isThrowing ? "throwing" : "") function.
      Parameters: \(paramList.isEmpty ? "none" : paramList)

      Use arrange-act-assert style. Only return the test body inside the function.
      """
  }
}
