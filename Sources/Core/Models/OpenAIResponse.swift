struct OpenAIRequest: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }

    let choices: [Choice]
}
