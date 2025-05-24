import Foundation
import SwiftParser
import SwiftSyntax

public class SwiftFileParser {
  public init() {}
  
  public func parseFile(at path: String) throws -> [ParsedType] {
    let url = URL(fileURLWithPath: path)
    let source = try String(contentsOf: url)

    let tree = Parser.parse(source: source)

    let visitor = TestGenVisitor(viewMode: .sourceAccurate)
    visitor.walk(tree)

    return visitor.parsedTypes
  }
}
