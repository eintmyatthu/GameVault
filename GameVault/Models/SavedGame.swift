import Foundation
import SwiftData

enum LibraryStatus: String, CaseIterable, Identifiable {
    case wantToPlay, playing, stopped
    var id: String { rawValue }
    var title: String {
        switch self {
        case .wantToPlay: "Wishlist"
        case .playing: "Playing"
        case .stopped: "Complete"
        }
    }
    var symbol: String {
        switch self {
        case .wantToPlay: "bookmark"
        case .playing: "gamecontroller"
        case .stopped: "stop.circle"
        }
    }
}

@Model
final class SavedGame {
    @Attribute(.unique, originalName: "rawgID") var gameID: Int
    var name: String
    var imageURL: String?
    var shortDescription: String?
    var gameURL: String?
    var publisher: String?
    var developer: String?
    var genreNames: [String]
    var platformNames: [String]
    var released: String?
    var metacritic: Int?
    var statusRaw: String?
    var isFavorite: Bool
    var personalRating: Int?
    var dateAdded: Date

    var status: LibraryStatus? {
        get {
            switch statusRaw {
            case "wishlist": .wantToPlay
            case "completed": .stopped
            default: statusRaw.flatMap(LibraryStatus.init(rawValue:))
            }
        }
        set { statusRaw = newValue?.rawValue }
    }
    init(game: Game) {
        gameID = game.id
        name = game.name
        imageURL = game.backgroundImage
        shortDescription = game.shortDescription
        gameURL = game.gameURL
        publisher = game.publisher
        developer = game.developer
        genreNames = game.genre.map { [$0] } ?? []
        platformNames = game.platform.map { [$0] } ?? []
        released = game.releaseDate
        metacritic = nil
        isFavorite = false
        personalRating = nil
        dateAdded = .now
    }
    var game: Game {
        Game(id: gameID, title: name, thumbnail: imageURL, shortDescription: shortDescription,
             gameURL: gameURL, genre: genreNames.first, platform: platformNames.first,
             publisher: publisher, developer: developer, releaseDate: released,
             freeToGameProfileURL: nil)
    }
}
