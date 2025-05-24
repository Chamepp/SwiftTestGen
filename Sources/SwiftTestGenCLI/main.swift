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
    let targetPath = target
    let sourcePath = source ?? "Sources/\(targetPath)"
    let testsRootDir = output ?? "Tests"

    let scanner = FileScanner()
    let parser = SwiftFileParser()
    let generator = TestGenerator()

    print("Scanning folder: \(sourcePath)")
    let files = scanner.swiftFiles(in: sourcePath)
    print("Found \(files.count) Swift files.")

    for file in files {
      do {
        let parsedTypes = try parser.parseFile(at: file)
        let testFileURL = URL(fileURLWithPath: testsRootDir)

        generator.generate(for: parsedTypes, target: targetPath, outputPath: testFileURL.path)

      } catch {
        print("Failed to parse file \(file): \(error)")
        fflush(stdout)
      }
    }

    print("Done.")
  }
}
