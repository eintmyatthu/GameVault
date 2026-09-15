import Foundation

struct Game: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let thumbnail: String?
    let shortDescription: String?
    let gameURL: String?
    let genre: String?
    let platform: String?
    let publisher: String?
    let developer: String?
    let releaseDate: String?
    let freeToGameProfileURL: String?

    var name: String { title }
    var backgroundImage: String? { thumbnail }
    var platformNames: String { platform ?? "Platform unavailable" }

    enum CodingKeys: String, CodingKey {
        case id, title, thumbnail, genre, platform, publisher, developer
        case shortDescription = "short_description"
        case gameURL = "game_url"
        case releaseDate = "release_date"
        case freeToGameProfileURL = "freetogame_profile_url"
    }
}

struct GameCategory: Identifiable, Hashable {
    let id: String
    let name: String

    static let common: [GameCategory] = [
        .init(id: "mmorpg", name: "MMORPG"), .init(id: "shooter", name: "Shooter"),
        .init(id: "strategy", name: "Strategy"), .init(id: "moba", name: "MOBA"),
        .init(id: "racing", name: "Racing"), .init(id: "sports", name: "Sports"),
        .init(id: "battle-royale", name: "Battle Royale"), .init(id: "card", name: "Card"),
        .init(id: "fighting", name: "Fighting"), .init(id: "action-rpg", name: "Action RPG"),
        .init(id: "sandbox", name: "Sandbox"), .init(id: "survival", name: "Survival")
    ]
}

enum GamePlatformFilter: String, CaseIterable, Identifiable {
    case all, pc, browser
    var id: String { rawValue }
    var title: String { rawValue == "pc" ? "PC" : rawValue.capitalized }
    var apiValue: String? { self == .all ? nil : rawValue }
}

enum GameSort: String, CaseIterable, Identifiable {
    case popularity
    case releaseDate = "release-date"
    case alphabetical
    case relevance
    var id: String { rawValue }
    var title: String {
        switch self {
        case .popularity: "Popularity"
        case .releaseDate: "Newest"
        case .alphabetical: "A–Z"
        case .relevance: "Relevance"
        }
    }
}
