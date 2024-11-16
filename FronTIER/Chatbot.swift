import Foundation

class Chatbot {
    static let shared = Chatbot()
    private let apiKey = "93b4d798-c552-47e5-bb95-f824805f4d8d" // Replace with your actual API Key
    private let endpoint = "https://api.sambanova.ai/v1/chat/completions"

    func sendMessage(_ message: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil, NSError(domain: "Chatbot", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Define the request body
        let requestBody: [String: Any] = [
            "model": "Meta-Llama-3.1-8B-Instruct",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant. End your response with <END>."
                ],
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 300,
            "stop_sequences": ["<END>"]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
        } catch {
            completion(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
            }

            guard let data = data else {
                completion(nil, NSError(domain: "Chatbot", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            // Parse the response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let responseText = content["content"] as? String {
                    completion(responseText, nil)
                } else {
                    let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                    completion(nil, NSError(domain: "Chatbot", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format: \(responseBody)"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
