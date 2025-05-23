import ArgumentParser
import Core
import Foundation

struct SwiftTestGenCLI: ParsableCommand {

  @Argument(help: "The target name to test.")
  var target: String

  @Option(name: .shortAndLong, help: "Source folder to scan (default: ./Sources/App)")
  var source: String?

  @Option(name: .shortAndLong, help: "Output path (default: ./Tests)")
  var output: String?

  func run() throws {
    let sourcePath = source ?? "Sources/\(target)"
    let testsRootDir = output ?? "Tests"

    print("Scanning folder: \(sourcePath)")
    let files = FileScanner.swiftFiles(in: sourcePath)
    print("Found \(files.count) Swift files.")

    let parser = SwiftFileParser()

    for file in files {
      do {
        let parsedTypes = try parser.parseFile(at: file)
        let testFileURL = URL(fileURLWithPath: testsRootDir)

        TestGenerator.generate(for: parsedTypes, target: target, outputPath: testFileURL.path)

      } catch {
        print("Failed to parse file \(file): \(error)")
        fflush(stdout)
      }
    }

    print("Done.")
  }
}
