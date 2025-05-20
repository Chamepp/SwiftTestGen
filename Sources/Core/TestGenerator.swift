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
        try? testCode.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
