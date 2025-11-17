import Foundation

struct GroqErrorResponse: Decodable {
    struct GroqError: Decodable {
        let message: String?
        let type: String?
    }
    let error: GroqError?
}

enum APIError: LocalizedError {
    case invalidURL, noData, apiError(message: String), unreadableServerError(statusCode: Int)
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .apiError(let message): return "Groq API Error: \(message)"
        case .unreadableServerError(let statusCode): return "HTTP Status \(statusCode)"
        }
    }
}

class GroqApiClient {
    private let apiKey = "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"
    private let baseURL = "https://api.groq.com/openai/v1"

    func chat(message: String,
              model: String = "llama3-8b-8192-groq",
              completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(APIError.invalidURL)); return
        }
        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": message]
            ]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        do { request.httpBody = try JSONSerialization.data(withJSONObject: payload) }
        catch { completion(.failure(error)); return }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data, let http = response as? HTTPURLResponse else {
                completion(.failure(APIError.noData)); return
            }
            if !(200...299).contains(http.statusCode) {
                // decode error on MainActor to satisfy Swift 6 isolation if types are actor-isolated
                Task {
                    await MainActor.run {
                        if let groqError = try? JSONDecoder().decode(GroqErrorResponse.self, from: data),
                           let message = groqError.error?.message {
                            completion(.failure(APIError.apiError(message: message)))
                        } else {
                            completion(.failure(APIError.unreadableServerError(statusCode: http.statusCode)))
                        }
                    }
                }
                return
            }
            // decode success on MainActor to avoid Swift 6 isolation issues
            Task {
                await MainActor.run {
                    do {
                        let response = try JSONDecoder().decode(GroqChatResponse.self, from: data)
                        let content = response.choices.first?.message.content ?? "No response"
                        completion(.success(content))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
}

struct GroqChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
