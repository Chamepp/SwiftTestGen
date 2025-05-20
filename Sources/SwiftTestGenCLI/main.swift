import ArgumentParser
import Core
import Foundation

struct SwiftTestGenCLI: ParsableCommand {

  @Argument(help: "The target name to test.")
  var target: String

  @Option(name: .shortAndLong, help: "Source folder to scan (default: ./Sources/Target)")
  var source: String?

  @Option(name: .shortAndLong, help: "Output path (default: ./Tests/TargetTests/GeneratedTests.swift)")
  var output: String?

    func run() throws {
      let sourcePath = source ?? "./Sources/\(target)"
      let outputPath = output ?? "./Tests/\(target)Tests/GeneratedTests.swift"

        print("Scanning folder: \(sourcePath)")
        let files = FileScanner.swiftFiles(in: sourcePath)
        print("Found \(files.count) Swift files.")

        print("Generating tests in: \(outputPath)")
        TestGenerator.generate(for: target, outputPath: outputPath)
        print("Done.")
    }
}
