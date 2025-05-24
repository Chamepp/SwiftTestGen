import Foundation
import SwiftParser
import SwiftSyntax

// SwiftFileParser is responsible for transforming a raw Swift file into a structured representation of types and functions.
// This separation ensures that parsing logic is isolated from file scanning and test generation responsibilities.
public class SwiftFileParser {

  // Public initializer allows other modules to create instances freely,
  // promoting modularity and reuse in different contexts (e.g., CLI, IDE integration, etc.).
  // The initializer will be improved and developed as the parser grows
  public init() {}

  // Parses the Swift file at the given path and returns an array of ParsedType.
  // This enables the CLI or generator to introspect classes, methods, and signatures for test generation.
  public func parseFile(at path: String) throws -> [ParsedType] {
    let url = URL(fileURLWithPath: path)

    // We read the raw contents of the file as a string.
    // This approach ensures maximum compatibility with source-level tools like SwiftSyntax,
    // which expect a raw source string rather than compiled representations.
    let source = try String(contentsOf: url)

    // We parse the source into a syntax tree using SwiftSyntax’s Parser.
    // This syntax tree retains formatting and structural details necessary for accurate parsing.
    let tree = Parser.parse(source: source)

    // TestGenVisitor is a custom SyntaxVisitor that walks the tree to collect structured information
    // (e.g., class names, method signatures). Using .sourceAccurate ensures we respect the original source layout,
    // which helps when generating precise and readable tests.
    let visitor = TestGenVisitor(viewMode: .sourceAccurate)
    visitor.walk(tree)

    // Return the parsed types collected by the visitor.
    // This structured output decouples the raw syntax tree from the higher-level model needed by the generator.
    return visitor.parsedTypes
  }
}
