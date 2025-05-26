import ArgumentParser
import Core
import Foundation

struct SwiftTestGenCLI: ParsableCommand {

  // We require the user to specify the target name because it determines
  // which module or app we're generating tests for. This enforces clarity
  // about the scope of the test generation.
  @Argument(help: "The target name to test.")
  var target: String

  // The source folder is optional because the default convention is to
  // scan the typical Sources folder for the given target, reducing the
  // need for explicit configuration in common cases.
  @Option(name: .shortAndLong, help: "Source folder to scan (default: ./Sources/App)")
  var source: String?

  // The output path for generated tests is also optional to encourage
  // sensible defaults while allowing flexibility when a custom location is needed.
  @Option(name: .shortAndLong, help: "Output path (default: ./Tests)")
  var output: String?

  func run() async throws {
    // Set paths based on input or fallbacks to default conventions.
    // This approach balances usability (no args needed) with flexibility.
    let targetPath = target
    let sourcePath = source ?? "Sources/\(targetPath)"
    let testsRootDir = output ?? "Tests"

    // Creating instances at the start makes the code clearer and
    // helps separate responsibilities: scanning files, parsing them,
    // and generating tests are distinct steps.
    let scanner = FileScanner()
    let parser = SwiftFileParser()
    let ai = AITestBodyGenerator()
    let generator = TestGenerator(bodyGenerator: ai)

    print("Scanning folder: \(sourcePath)")

    // Scanning the folder to collect relevant Swift source files ensures
    // that we only work with files that matter, improving efficiency and correctness.
    let files = scanner.swiftFiles(in: sourcePath)
    print("Found \(files.count) Swift files.")

    for file in files {
      do {
        // Parsing each file transforms raw source code into structured data,
        // enabling us to generate precise, tailored tests rather than guesswork.
        let parsedTypes = try parser.parseFile(at: file)



        // Converts parsed type information into XCTest-compatible test files.
        // This step transforms the static analysis of source code into concrete test code.
        // Generated files are written to the specified output directory to scaffold test
        // coverage for the target. Later these test files will be updated with the AI generated
        // content with `AITestBodyGenerator` injected earlier.
        await generator.generate(for: parsedTypes, target: targetPath, outputPath: testsRootDir)

      } catch {
        // Robust error handling here prevents a single failure from stopping
        // the whole process and provides actionable feedback to the user.
        print("Failed to parse file \(file): \(error)")
        fflush(stdout)
      }
    }

    // A clear indication that the process has completed successfully,
    // improving user experience by closing the feedback loop.
    print("Done.")
  }
}
