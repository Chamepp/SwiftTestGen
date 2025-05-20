import PackagePlugin
import Foundation

@main
struct SwiftTestGenPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tool = try context.tool(named: "SwiftTestGenCLI")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: tool.path.string)
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()
    }
}
