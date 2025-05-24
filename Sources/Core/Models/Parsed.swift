public struct ParsedType {
  public let typeName: String  // Class, struct, enum or protocol name
  public let functions: [ParsedFunction]  // Functions inside the type

  public init(typeName: String, functions: [ParsedFunction]) {
    self.typeName = typeName
    self.functions = functions
  }
}

public struct ParsedFunction {
  public let name: String
  public let isAsync: Bool
  public let isThrowing: Bool
  public let parameters: [String]  // ["paramName: Type", ...]
  public let body: String  // e.g. func greet() { print("Hello World") } -> print("Hello World")
  public let returnType: String?  // e.g. "Void" or "String"

  public init(
    name: String, isAsync: Bool, isThrowing: Bool, parameters: [String], body: String, returnType: String?
  ) {
    self.name = name
    self.isAsync = isAsync
    self.isThrowing = isThrowing
    self.parameters = parameters
    self.body = body
    self.returnType = returnType
  }
}
