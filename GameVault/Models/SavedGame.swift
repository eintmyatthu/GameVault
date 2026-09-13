import Foundation
import SwiftData

enum LibraryStatus: String, CaseIterable, Identifiable {
    case wishlist, playing, completed
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .wishlist: "bookmark"
        case .playing: "gamecontroller"
        case .completed: "checkmark.circle"
        }
    }
}

@Model
final class SavedGame {
    @Attribute(.unique) var rawgID: Int
    var name: String
    var imageURL: String?
    var rating: Double?
    var genreNames: [String]
    var platformNames: [String]
    var released: String?
    var metacritic: Int?
    var statusRaw: String?
    var isFavorite: Bool
    var dateAdded: Date

    var status: LibraryStatus? {
        get { statusRaw.flatMap(LibraryStatus.init(rawValue:)) }
        set { statusRaw = newValue?.rawValue }
    }
    init(game: Game) {
        rawgID = game.id
        name = game.name
        imageURL = game.backgroundImage
        rating = game.rating
        genreNames = game.genres?.map(\.name) ?? []
        platformNames = game.platforms?.map(\.platform.name) ?? []
        released = game.released
        metacritic = game.metacritic
        isFavorite = false
        dateAdded = .now
    }
    var game: Game {
        Game(id: rawgID, name: name, backgroundImage: imageURL, rating: rating,
             released: released, metacritic: metacritic,
             platforms: platformNames.enumerated().map { GamePlatform(platform: NamedResource(id: $0.offset, name: $0.element)) },
             genres: genreNames.enumerated().map { NamedResource(id: $0.offset, name: $0.element) })
    }
}
