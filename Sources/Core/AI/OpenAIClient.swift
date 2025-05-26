import Foundation

// Singleton client responsible for interacting with the OpenAI API.
// This design pattern is for temporary usage and will be changed soon
// since it makes testing problematic and inaccurate. Centralizing API
// logic here provides a clean separation of concerns, making
// the AI interaction reusable, testable, and decoupled from other layers.
public final class OpenAIClient {

    // Shared instance ensures consistent configuration and enables dependency injection.
    public static let shared = OpenAIClient()

    // Fetches the OpenAI API key from environment variables.
    // This prevents hardcoding secrets and allows different environments (e.g., local, CI/CD) to securely configure access.
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

    // Defines the endpoint for the chat completion API.
    // Abstracted into a constant to ensure maintainability if URLs change.
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    // The selected OpenAI model used for test generation.
    // Keeping this explicit improves clarity and lets developers easily upgrade/downgrade the model.
    private let model = "gpt-4"

    // Generates a test function body by sending a structured prompt to the OpenAI API.
    // Encapsulates the full request/response logic, throwing meaningful errors on failure.
    public func generate(prompt: String) async throws -> String {
        // Ensure API key is set before attempting a request.
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }

        // Constructs the message payload for the OpenAI chat model.
        // The system message defines the assistant's behavior to return only Swift test bodies,
        // keeping the output clean, focused, and usable directly in code generation.
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an expert in Swift testing. Only return the test function body."],
            ["role": "user", "content": prompt]
        ]

        // Wraps all necessary data into a payload object that conforms to OpenAI's expected input schema.
        let payload = OpenAIRequest(model: model, messages: messages, temperature: 0.2)

        // Constructs the HTTP request to OpenAI's endpoint with appropriate headers and body.
        // Uses bearer token for secure authentication and sets JSON content type.
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        // Sends the request asynchronously and handles the response.
        // This makes the API call non-blocking and suitable for concurrent tasks like batch test generation.
        let (data, response) = try await URLSession.shared.data(for: request)

        // Ensures the HTTP status code indicates success (200 OK).
        // Guards against partial failures or server errors.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OpenAIError.invalidResponse
        }

        // Attempts to decode the response JSON into the expected format.
        // Errors in decoding (e.g., schema mismatch) are surfaced clearly.
        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        // Extracts and cleans the generated content from the response.
        // Returns only the test function body, ready to be injected into generated test stubs.
        return decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
