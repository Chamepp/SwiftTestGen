import Foundation

public struct TestGenerator {
    public static func generate(for target: String, outputPath: String) {
        let testCode = """
        import XCTest
        @testable import \(target)

        final class GeneratedTests: XCTestCase {
            func testExample() {
                XCTAssertTrue(true)
            }
        }
        """

        let fileURL = URL(fileURLWithPath: outputPath)
        let outputDir = fileURL.deletingLastPathComponent()

        do {
            // Create directory if it doesn’t exist
            try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

            // Write the file
            try testCode.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write file: \(error)")
        }
    }
}
