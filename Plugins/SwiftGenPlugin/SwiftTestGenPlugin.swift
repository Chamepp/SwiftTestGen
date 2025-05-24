import Foundation
import PackagePlugin

// This plugin allows the `SwiftTestGenCLI` tool to be executed as a SwiftPM command plugin.
// Users can run it from the command line using `swift package` commands.
// Plugins like this provide custom automation in Swift projects.
@main
struct SwiftTestGenPlugin: CommandPlugin {

  // This is the main entry point of the plugin when invoked by SwiftPM.
  // It receives the plugin context (project structure and tools) and any CLI arguments passed.
  func performCommand(context: PluginContext, arguments: [String]) async throws {

    // Locate the prebuilt binary tool named "SwiftTestGenCLI" declared in the plugin's manifest.
    // This allows the plugin to delegate its behavior to a compiled command-line utility.
    let tool = try context.tool(named: "SwiftTestGenCLI")

    // Set up a Process to run the CLI tool using its path.
    // This allows you to use all the CLI logic separately, keeping the plugin lightweight.
    let process = Process()
    process.executableURL = URL(fileURLWithPath: tool.path.string)
    process.arguments = arguments

    // Start the CLI tool process and wait for it to finish.
    // This step ensures the plugin acts as a simple wrapper, forwarding arguments.
    try process.run()
    process.waitUntilExit()
  }
}
