import Foundation
import Observation
import SwiftData

@MainActor @Observable
final class LibraryViewModel {
    var errorMessage: String?
    var feedback: String?

    // One unique RAWG ID stores both collection and favorite state.
    func save(_ game: Game, status: LibraryStatus? = nil, toggleFavorite: Bool = false, in context: ModelContext) {
        do {
            let id = game.id
            let descriptor = FetchDescriptor<SavedGame>(predicate: #Predicate { $0.rawgID == id })
            let existing = try context.fetch(descriptor).first
            let saved = existing ?? SavedGame(game: game)
            if existing == nil { context.insert(saved) }
            if let status { saved.status = status }
            if toggleFavorite { saved.isFavorite.toggle() }
            let message = toggleFavorite ? (saved.isFavorite ? "Added to favorites" : "Removed from favorites") : "Saved to \(status?.title ?? "library")"
            if saved.status == nil && !saved.isFavorite { context.delete(saved) }
            try context.save()
            feedback = message
        } catch {
            context.rollback()
            errorMessage = "Your change couldn't be saved. Please try again."
        }
    }
    func removeFromLibrary(_ saved: SavedGame, in context: ModelContext) {
        saved.status = nil
        if !saved.isFavorite { context.delete(saved) }
        do {
            try context.save()
            feedback = "Removed from library"
        } catch {
            context.rollback()
            errorMessage = "The game couldn't be removed. Please try again."
        }
    }
}
