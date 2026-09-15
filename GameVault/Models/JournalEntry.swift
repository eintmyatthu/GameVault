import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var gameID: Int
    var gameName: String
    var date: Date
    var text: String
    var createdAt: Date

    init(gameID: Int, gameName: String, date: Date, text: String) {
        id = UUID()
        self.gameID = gameID
        self.gameName = gameName
        self.date = date
        self.text = text
        createdAt = .now
    }
}
