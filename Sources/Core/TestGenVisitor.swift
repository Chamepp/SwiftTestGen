import Foundation
import SwiftSyntax

public class TestGenVisitor: SyntaxVisitor {
  // Store the final parsed types
  public private(set) var parsedTypes: [ParsedType] = []

  // Stack to support nested types.
  // Each element holds (typeName, collectedFunctions)
  private var typeStack: [(name: String, functions: [ParsedFunction])] = []

  // When we enter a type declaration, push a new context onto the stack.
  public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: ClassDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: StructDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: EnumDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
    typeStack.append((node.name.text, []))
    return .visitChildren
  }

  public override func visitPost(_ node: ProtocolDeclSyntax) {
    let completed = typeStack.removeLast()
    parsedTypes.append(ParsedType(typeName: completed.name, functions: completed.functions))
  }

  public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let functionName = node.name.text

    // Check if the function is async and/or throwing
    let isAsync = node.signature.effectSpecifiers?.asyncSpecifier != nil
    let isThrowing = node.signature.effectSpecifiers?.throwsSpecifier != nil

    // Get return type, if any
    let returnType = node.signature.returnClause?.type.description.trimmingCharacters(
      in: .whitespacesAndNewlines)

    // Extract parameters as "name: Type"
    let parameters = node.signature.parameterClause.parameters.map { param -> String in
      let paramName = param.firstName.text
      let paramType = param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
      return "\(paramName): \(paramType)"
    }

    let function = ParsedFunction(
      name: functionName,
      isAsync: isAsync,
      isThrowing: isThrowing,
      parameters: parameters,
      returnType: returnType
    )

    // Add function to the current top type context if any
    if var current = typeStack.last {
      current.functions.append(function)
      typeStack[typeStack.count - 1] = current
    }

    return .skipChildren  // No need to go deeper inside function node
  }
}
