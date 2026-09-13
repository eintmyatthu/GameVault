import Foundation

struct GameDetail: Codable {
    let id: Int
    let name: String
    let backgroundImage: String?
    let rating: Double?
    let released: String?
    let metacritic: Int?
    let platforms: [GamePlatform]?
    let genres: [NamedResource]?
    let descriptionRaw: String?
    let developers: [NamedResource]?
    let publishers: [NamedResource]?
    let esrbRating: NamedResource?
    let website: String?

    var game: Game {
        Game(id: id, name: name, backgroundImage: backgroundImage, rating: rating,
             released: released, metacritic: metacritic, platforms: platforms, genres: genres)
    }
    enum CodingKeys: String, CodingKey {
        case id, name, rating, released, metacritic, platforms, genres, developers, publishers, website
        case backgroundImage = "background_image"
        case descriptionRaw = "description_raw"
        case esrbRating = "esrb_rating"
    }
}
