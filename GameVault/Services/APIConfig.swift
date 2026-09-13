import Foundation

enum APIConfig {
    static let baseURL = "https://api.rawg.io/api"
    static let apiKeyPlaceholder = "PUT_YOUR_RAWG_API_KEY_HERE"

    // For a local run, set RAWG_API_KEY in Scheme > Run > Arguments > Environment Variables.
    // Alternatively replace the placeholder below. Never commit your real key.
    static let rawgAPIKey: String = {
        let environmentKey = ProcessInfo.processInfo.environment["RAWG_API_KEY"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let environmentKey, !environmentKey.isEmpty {
            return environmentKey
        }

        return apiKeyPlaceholder
    }()
}
