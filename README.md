# SwiftTestGen

**SwiftTestGen** is a SwiftPM plugin and command-line tool that uses AI to automatically generate unit tests for your Swift packages. The goal is to accelerate test coverage with intelligent, context-aware test generation directly integrated into the Swift developer workflow.

**SwiftTestGen** levarages the new SwiftPM introduced by apple with the help of SwiftArgumentParser, and auto generates unit tests for our target development with the help of swift syntax and ai.

> ⚠️ **Currently in active development.**  
> The features described below represent the planned vision. Follow along as we ship core functionality step by step!

---

## Current Development Stage

We are currently building the foundation of the system, which includes:

- **Plugin architecture setup** using Swift Package Manager
- **Modular structure** with reusable Core logic
- **Command-line interface** via `swift-argument-parser`
- **Connecting AI model (coming soon)**
- **Test generation logic based on Swift source code analysis using swift syntax**
- **Plugin integration into Xcode and SwiftPM workflows**

## What Will SwiftTestGen Do?

When completed, SwiftTestGen will:

- Analyze your Swift source code using static analysis
- Communicate with an AI backend (e.g., OpenAI or local LLMs)
- Generate `XCTestCase` classes and test methods automatically
- Offer a CLI and SwiftPM plugin to run test generation via:
```bash
  swift package generate-tests
```
Output unit tests into your Tests/ folder with full structure

## How Will Developers Use It?
Once published, you’ll be able to add it to your Package.swift like this:
```swift
.package(url: "https://github.com/yourusername/swifttestgen", from: "1.0.0")
```

Then run the plugin:

```bash
swift package generate-tests
```

Or invoke the CLI directly:

```bash
swift run SwiftTestGenCLI MyTargetName
```
