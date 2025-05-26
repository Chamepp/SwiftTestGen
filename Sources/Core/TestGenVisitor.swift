import Foundation
import SwiftSyntax

// TestGenVisitor walks through a SwiftSyntax syntax tree and collects structured metadata
// about top-level types (classes, structs, enums, protocols) and their function declarations.
// This isolates traversal logic from parsing and generation concerns, keeping responsibilities clean.
public class TestGenVisitor: SyntaxVisitor {

  // Exposes the final result: a list of parsed types with their associated functions.
  // Using `public private(set)` allows external consumers to read the parsed data without modifying it,
  // preserving data integrity after parsing.
  public private(set) var parsedTypes: [ParsedType] = []

  // A stack is used to support nesting (e.g., types inside types),
  // ensuring correct function association with their parent type during traversal.
  private var typeStack: [(name: String, functions: [ParsedFunction])] = []

  // Visiting a class declaration: push a new context onto the stack.
  // This begins the scope for collecting class-specific functions.
  public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  // When we finish visiting a class, we pop its context and record the completed type.
  // This ensures all functions collected while inside the class are correctly grouped.
  public override func visitPost(_ node: ClassDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  // Same pattern applies for structs: isolate scope and group methods appropriately.
  public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: StructDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  // Enums are also visited in the same scoped manner. This allows test generation
  // to support all common Swift type declarations.
  public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: EnumDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  // Protocols are included for completeness, as they define expected behaviors and can be tested via mocks or stubs.
  public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: ProtocolDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  // When encountering a function declaration inside a type, we extract the necessary metadata.
  // This includes function name, parameters, return type, and whether it supports async or throws behavior.
  public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let functionName = node.name.text

    // Determines whether this function uses Swift concurrency or error handling
    let isAsync = node.signature.effectSpecifiers?.asyncSpecifier != nil
    let isThrowing = node.signature.effectSpecifiers?.throwsSpecifier != nil

    // Extract the function parameters, formatting them as "name: Type"
    // so they can be used directly in function calls or test templates.
    let parameters = node.signature.parameterClause.parameters.map { param -> String in
      let paramName = param.firstName.text
      let paramType = param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
      return "\(paramName): \(paramType)"
    }

    // Walking deeper into the function body;
    // This section aims at AI test generation by extracting function body source code as a string
    // We pass the function body for AI test generation
    let body: String
    if let bodyNode = node.body {
      // Convert the CodeBlockSyntax node back to String preserving formatting
      body = bodyNode.description.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      // For function declarations without bodies (e.g., protocol requirements, stubs)
      body = "// Empty function"
    }

    // Capture the return type if one exists. This helps identify pure functions vs. void operations.
    let returnType = node.signature.returnClause?.type.description.trimmingCharacters(
      in: .whitespacesAndNewlines
    )

    // Construct a ParsedFunction object to store the collected function details.
    let function = ParsedFunction(
      name: functionName,
      isAsync: isAsync,
      isThrowing: isThrowing,
      parameters: parameters,
      body: body,
      returnType: returnType
    )

    // Append the function to the current type's context.
    // By modifying the top of the stack, we ensure correct grouping of functions under the right type.
    if var current = typeStack.last {
      current.functions.append(function)
      typeStack[typeStack.count - 1] = current
    }

    return .skipChildren
  }
}
