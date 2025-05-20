import ArgumentParser

struct SwiftTestGenCLI: ParsableCommand {
  @Option(name: .shortAndLong, help: "Path to the source file")
  var path: String

  func run() throws {
    let source = try String(contentsOfFile: path)
//    let tests = TestGenerator().generateTests(from: source)
//    print(tests)
  }
}
