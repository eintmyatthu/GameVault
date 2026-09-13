import Foundation

enum RAWGError: LocalizedError {
    case missingKey
    case invalidURL
    case invalidKey
    case rateLimited
    case http(Int)
    case decoding
    case offline
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .missingKey: "Connect your RAWG account by adding your API key in APIConfig.swift or the RAWG_API_KEY scheme environment variable."
        case .invalidURL: "The game request could not be created. Please try again."
        case .invalidKey: "RAWG rejected the API key. Please check your key and try again."
        case .rateLimited: "RAWG is receiving too many requests. Please try again shortly."
        case .http(let code): "RAWG could not complete the request (\(code)). Please try again."
        case .decoding: "We couldn't read RAWG's response. Please try again later."
        case .offline: "We couldn't connect to RAWG. Check your internet connection and retry. Your saved library is still available."
        case .network: "The RAWG request failed. Please try again."
        }
    }
}

struct RAWGService {
    var session: URLSession = .shared

    func popularGames() async throws -> [Game] {
        try await games(query: ["ordering": "-added"])
    }
    func topRatedGames() async throws -> [Game] {
        try await games(query: ["ordering": "-metacritic", "metacritic": "80,100"])
    }
    func recentGames() async throws -> [Game] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let today = Date()
        let start = Calendar.current.date(byAdding: .month, value: -3, to: today) ?? today
        return try await games(query: ["ordering": "-released", "dates": "\(formatter.string(from: start)),\(formatter.string(from: today))"])
    }
    func searchGames(text: String, genre: String?, page: Int = 1) async throws -> GameResponse {
        var query = ["page_size": "20", "page": String(page)]
        if !text.isEmpty { query["search"] = text }
        if let genre { query["genres"] = genre }
        return try await request(path: "games", query: query)
    }
    func genres() async throws -> [NamedResource] {
        let response: GenreResponse = try await request(path: "genres", query: ["page_size": "40"])
        return response.results
    }
    func detail(id: Int) async throws -> GameDetail {
        try await request(path: "games/\(id)")
    }
    private func games(query: [String: String]) async throws -> [Game] {
        var query = query
        query["page_size"] = "15"
        let response: GameResponse = try await request(path: "games", query: query)
        return response.results
    }
    private func request<T: Decodable>(path: String, query: [String: String] = [:]) async throws -> T {
        let key = APIConfig.rawgAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key != APIConfig.apiKeyPlaceholder else {
            throw RAWGError.missingKey
        }

        guard var components = URLComponents(string: "\(APIConfig.baseURL)/\(path)") else {
            throw RAWGError.invalidURL
        }

        var queryItems = query
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "key", value: key))
        components.queryItems = queryItems

        guard let url = components.url else { throw RAWGError.invalidURL }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw RAWGError.http(0) }
            switch http.statusCode {
            case 200..<300: break
            case 401, 403: throw RAWGError.invalidKey
            case 429: throw RAWGError.rateLimited
            default: throw RAWGError.http(http.statusCode)
            }
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw RAWGError.decoding }
        } catch let error as URLError {
            if error.code == .cancelled { throw CancellationError() }
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
                 .cannotConnectToHost, .dnsLookupFailed, .internationalRoamingOff:
                throw RAWGError.offline
            default:
                throw RAWGError.network(error)
            }
        }
    }
}
