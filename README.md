<p align="center">
  <img src="https://github.com/yourusername/SwiftTestGen/Logo.png" alt="SwiftTestGen Logo" width="120"/>
</p>

<h1 align="center">SwiftTestGen</h1>

<p align="center">
  A SwiftPM plugin and command-line tool that intelligently generates unit tests <br />
  for your Swift packages using static analysis and AI.
</p>


## Overview

**SwiftTestGen** accelerates test coverage by automatically generating test cases using static code analysis and OpenAI’s language model. It helps developers reduce repetitive test writing, increase confidence in coverage, and maintain a clean test structure that integrates directly into their existing Swift workflows.

This tool automates the most tedious parts of test authoring—such as boilerplate, setup logic, and assertion patterns—by analyzing Swift source code and generating `XCTestCase` subclasses with meaningful test functions.



## Key Motivation

In modern software development, writing unit tests is essential but often delayed or skipped due to common challenges:

* Test writing is repetitive and time-consuming.
* Developers often struggle with edge cases and coverage completeness.
* Writing tests for complex logic requires deep familiarity with both the implementation and the testing framework.
* Deadlines and task switching deprioritize tests, resulting in technical debt.

SwiftTestGen addresses these problems directly by automating the generation of structured test functions based on your existing code—reducing cognitive load while maintaining code quality.


## What SwiftTestGen Offers

SwiftTestGen brings together several technologies to streamline testing in Swift projects:

* **Static Code Analysis**: Uses `SwiftSyntax` to parse Swift code and extract function metadata.
* **AI-Powered Test Generation**: Integrates with OpenAI to generate context-aware test function bodies using the Arrange-Act-Assert pattern.
* **Modular Plugin Architecture**: Built as a SwiftPM plugin with a reusable and extensible core.
* **Command-Line Interface**: Built with `swift-argument-parser` for terminal usage.


## Current Development Stage

SwiftTestGen is actively under development. The following core features are now functional:

* SwiftPM plugin structure and CLI using `swift-argument-parser`
* Static parsing of Swift types and methods using `SwiftSyntax`
* Integration with OpenAI for intelligent test body generation
* Automatic generation of `XCTestCase` classes and test method stubs
* Outputting generated test files into the `Tests/` directory
* Seamless usage through `swift package generate-tests` or via direct CLI call


## Usage

Add SwiftTestGen as a plugin to your package:

```swift
// Package.swift
.package(url: "https://github.com/yourusername/SwiftTestGen", from: "1.0.0")
```

Then run the plugin:

```bash
swift package generate-tests
```

Or use the CLI directly:

```bash
swift run SwiftTestGenCLI MyTargetName
```

This will analyze your source code and generate test files under your `Tests/` folder, following the existing module structure.


## Example Workflow

1. You define your core logic in a Swift package.
2. You run SwiftTestGen either from CLI or as a plugin.
3. SwiftTestGen:

   * Parses your Swift types and functions
   * Sends prompts to the AI with full context about each method
   * Receives a fully formed test body using best practices
   * Writes the corresponding `XCTestCase` class with embedded test methods


## Why Use AI for Test Generation?

Traditional code generation tools can only create boilerplate. By using a language model, SwiftTestGen is capable of:

* Understanding function signatures, parameters, and edge cases
* Producing high-quality test logic following common patterns
* Tailoring assertions and setups dynamically based on function context

This leads to more meaningful test scaffolding, saving developers hours of manual effort and helping teams enforce consistent test writing across large codebases.


## Contributing

Contributions are welcome as we continue developing core features and improving integration. Please open an issue or submit a pull request for:

* Feature enhancements
* Plugin improvements
* Support for additional test frameworks
* Integration with local LLMs


## License

This project is released under the MIT License.

