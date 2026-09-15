import Foundation

enum FreeToGameError: LocalizedError {
    case invalidURL, notFound, decoding, offline
    case http(Int)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The game request could not be created. Please try again."
        case .notFound: "No matching free-to-play games were found."
        case .http(let code): "FreeToGame could not complete the request (\(code)). Please try again."
        case .decoding: "We couldn't read FreeToGame's response. Please try again later."
        case .offline: "We couldn't connect to FreeToGame. Check your internet connection and retry. Your backlog and journal are still available."
        case .network: "The FreeToGame request failed. Please try again."
        }
    }
}

struct FreeToGameService {
    var session: URLSession = .shared

    func games(platform: String? = nil, category: String? = nil, sort: GameSort = .popularity) async throws -> [Game] {
        var query = ["sort-by": sort.rawValue]
        if let platform { query["platform"] = platform }
        if let category { query["category"] = category }
        return try await request(path: "games", query: query)
    }

    func detail(id: Int) async throws -> GameDetail {
        try await request(path: "game", query: ["id": String(id)])
    }

    private func request<T: Decodable>(path: String, query: [String: String]) async throws -> T {
        guard var components = URLComponents(string: "\(APIConfig.baseURL)/\(path)") else { throw FreeToGameError.invalidURL }
        components.queryItems = query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw FreeToGameError.invalidURL }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw FreeToGameError.http(0) }
            switch http.statusCode {
            case 200..<300: break
            case 404: throw FreeToGameError.notFound
            default: throw FreeToGameError.http(http.statusCode)
            }
            do { return try JSONDecoder().decode(T.self, from: data) }
            catch { throw FreeToGameError.decoding }
        } catch let error as URLError {
            if error.code == .cancelled { throw CancellationError() }
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
                 .cannotConnectToHost, .dnsLookupFailed, .internationalRoamingOff:
                throw FreeToGameError.offline
            default: throw FreeToGameError.network(error)
            }
        }
    }
}
