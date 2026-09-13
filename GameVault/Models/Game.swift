import Foundation

struct NamedResource: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    var slug: String?
}

struct GamePlatform: Codable, Hashable {
    let platform: NamedResource
}

struct Game: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    var backgroundImage: String?
    var rating: Double?
    var released: String?
    var metacritic: Int?
    var platforms: [GamePlatform]?
    var genres: [NamedResource]?

    var platformNames: String {
        let names = platforms?.map(\.platform.name) ?? []
        return names.isEmpty ? "Platforms unavailable" : names.joined(separator: " · ")
    }
    var ratingText: String {
        guard let rating, rating > 0 else { return "Unrated" }
        return String(format: "%.1f", rating)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, rating, released, metacritic, platforms, genres
        case backgroundImage = "background_image"
    }
}

struct GameResponse: Codable {
    let results: [Game]
    let next: String?
}

struct GenreResponse: Codable {
    let results: [NamedResource]
}
