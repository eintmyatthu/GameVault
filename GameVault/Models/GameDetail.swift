import Foundation

struct GameScreenshot: Codable, Hashable, Identifiable {
    let id: Int
    let image: String
}

struct MinimumSystemRequirements: Codable, Hashable {
    let os: String?
    let processor: String?
    let memory: String?
    let graphics: String?
    let storage: String?
}

struct GameDetail: Codable {
    let id: Int
    let title: String
    let thumbnail: String?
    let status: String?
    let shortDescription: String?
    let description: String?
    let gameURL: String?
    let genre: String?
    let platform: String?
    let publisher: String?
    let developer: String?
    let releaseDate: String?
    let freeToGameProfileURL: String?
    let minimumSystemRequirements: MinimumSystemRequirements?
    let screenshots: [GameScreenshot]?

    var game: Game {
        Game(id: id, title: title, thumbnail: thumbnail, shortDescription: shortDescription,
             gameURL: gameURL, genre: genre, platform: platform, publisher: publisher,
             developer: developer, releaseDate: releaseDate,
             freeToGameProfileURL: freeToGameProfileURL)
    }

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, status, description, genre, platform, publisher, developer, screenshots
        case shortDescription = "short_description"
        case gameURL = "game_url"
        case releaseDate = "release_date"
        case freeToGameProfileURL = "freetogame_profile_url"
        case minimumSystemRequirements = "minimum_system_requirements"
    }
}
