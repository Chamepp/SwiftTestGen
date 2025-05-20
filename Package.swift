// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftTestGen",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .plugin(name: "SwiftTestGenPlugin", targets: ["SwiftTestGenPlugin"]),
        .executable(name: "SwiftTestGenCLI", targets: ["SwiftTestGenCLI"])
    ],
    dependencies: [
        // Swift Argument Parser for CLI interface
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        // Core logic module (reusable by CLI)
        .target(
            name: "Core",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),

        // CLI tool that uses Core and ArgumentParser
        .executableTarget(
            name: "SwiftTestGenCLI",
            dependencies: [
                "Core",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),

        // SwiftPM plugin target
        .plugin(
            name: "SwiftTestGenPlugin",
            capability: .command(
                intent: .custom(verb: "generate-tests", description: "Generates unit tests using AI"),
                permissions: [.writeToPackageDirectory(reason: "Write generated test files")]
            ),
            dependencies: [
                .target(name: "SwiftTestGenCLI")
            ]
        ),

        // Tests for Core logic
        .testTarget(
            name: "SwiftTestGenTests",
            dependencies: [
                "Core",
                "SwiftTestGenCLI"
            ]
        ),
    ]
)
