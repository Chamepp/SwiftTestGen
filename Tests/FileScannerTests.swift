import XCTest
@testable import Core

final class FileScannerTests: XCTestCase {
    var tempDirectoryURL: URL!

    override func setUpWithError() throws {
        tempDirectoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

        // Create mock Swift files
        let files = [
            "AppDelegate.swift",
            "HomeViewController.swift",
            "Utils.swift",
            "README.md",                // should be ignored
            "Home.storyboard"          // should be ignored
        ]

        let sourcesDir = tempDirectoryURL.appendingPathComponent("Sources/MyApp")
        try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

        for file in files {
            let fileURL = sourcesDir.appendingPathComponent(file)
            try "print(\"Hello\")".write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: tempDirectoryURL)
    }

    func testSwiftFileDiscovery() throws {
        let path = tempDirectoryURL.appendingPathComponent("Sources/MyApp").path
        let swiftFiles = FileScanner.swiftFiles(in: path)

        XCTAssertEqual(swiftFiles.count, 3, "Should find only .swift files")
        XCTAssertTrue(swiftFiles.allSatisfy { $0.hasSuffix(".swift") })
    }
}

