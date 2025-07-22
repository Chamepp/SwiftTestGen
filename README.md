<p align="center">
  <img width="200" height="200" alt="image (2)" src="https://github.com/user-attachments/assets/90282ce5-3aa6-462f-b46a-20f2c17305cf" />
</p>

<h1 align="center">SwiftTestGen</h1>

<p align="center">
  A SwiftPM plugin and command-line tool that intelligently generates unit tests <br />
  for your Swift packages using static analysis and AI.
</p>

## Introduction
<p align="left">
  Code is fast. Testing is slow.  
  SwiftTestGen bridges the gap.  
  No more boilerplate. No more test debt.  
  Just clean, structured, AI-generated tests — right from your Swift code.
</p>

<p align="left"><em>“The best time to write tests was yesterday. The second-best time is now.”</em><br><strong>—Kent Beck</strong></p>

<p align="left">
  Testing isn’t optional. But writing tests manually? That should be.  
  SwiftTestGen reads your code, understands it, and writes meaningful tests for you.  
  Powered by static analysis. Enhanced with OpenAI.  
  Built to fit the way you already work.
</p>

<p align="left"><em>“Developers using AI will replace those who don’t.”</em></p>

<p align="left">
  From startups to scale — your tests stay sharp.  
  From simple functions to deep logic — your edge cases get covered.  
  Ship faster. Sleep better.
</p>

## What Is SwiftTestGen?

**SwiftTestGen** is an intelligent test generation tool for Swift packages.

It scans your Swift code using static analysis and generates unit tests using AI.  
Use it as a SwiftPM plugin or from the command line — it’s modular, extensible, and fast.

Whether you're just starting a project or growing a large codebase, SwiftTestGen helps you:

- Catch bugs early  
- Enforce testing discipline  
- Increase coverage with less effort  

## Why SwiftTestGen?

Testing is critical. But testing is also:

- Repetitive  
- Time-consuming  
- Easy to skip under pressure  

Manual tests take time. Unwritten tests cost even more.

> _“Automation is good, so long as you know exactly where to put the machine.”_  
> **—Elon Musk**

SwiftTestGen puts the machine in the right place: between your code and your confidence.

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
   - Parses your Swift types and functions
   - Sends prompts to the AI with full context about each method
   - Receives a fully formed test body using best practices
   - Writes the corresponding `XCTestCase` class with embedded test methods


## Why Use AI for Test Generation?

Traditional test tools create structure.
SwiftTestGen creates substance.

AI understands:
- Your function’s intent
- Your edge cases
- Your naming conventions
- Your expected behaviors

Tools that understand our code free us to focus on what matters.

SwiftTestGen doesn’t just make testing easier, it makes it smarter.

## Contributing

Contributions are welcome as we continue developing core features and improving integration. Please open an issue or submit a pull request for:

* Feature enhancements
* Plugin improvements
* Support for additional test frameworks
* Integration with local LLMs


## License

This project is released under the MIT License.

