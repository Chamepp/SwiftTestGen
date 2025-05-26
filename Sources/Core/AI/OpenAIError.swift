import Foundation

// Defines errors specific to interactions with the OpenAI API.
// Encapsulating these cases in a dedicated enum improves error clarity,
// centralizes failure handling, and enables more meaningful user-facing error messages.
public enum OpenAIError: Error, LocalizedError {

  // Thrown when the required API key is not found in the environment.
  // This prevents unauthorized or unauthenticated API requests.
  case missingAPIKey

  // Indicates that the API returned a response that could not be interpreted
  // as valid or expected. Helps detect contract mismatches or backend issues.
  case invalidResponse

  // Represents a failure in decoding the JSON response into the expected data model.
  // Highlights deserialization issues, often caused by schema drift or malformed data.
  case decodingError

  // Fallback error type for unexpected failures that don't fit known categories.
  // Ensures all failure cases are covered without crashing.
  case unknown

  // Provides a human-readable explanation for each error type.
  // This improves debugging and can be surfaced directly in UI or logs
  // for better developer experience and traceability.
  public var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "Missing OpenAI API key. Please set the OPENAI_API_KEY environment variable."
    case .invalidResponse:
      return "Invalid response from OpenAI API."
    case .decodingError:
      return "Failed to decode the response from OpenAI."
    case .unknown:
      return "An unknown error occurred."
    }
  }
}
