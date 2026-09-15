import Foundation
import Observation
import SwiftData

@MainActor @Observable
final class LibraryViewModel {
    var errorMessage: String?
    var feedback: String?

    // One unique API ID stores collection, favorite, and personal-rating state.
    func save(_ game: Game, status: LibraryStatus? = nil, toggleFavorite: Bool = false, in context: ModelContext) {
        do {
            let id = game.id
            let descriptor = FetchDescriptor<SavedGame>(predicate: #Predicate { $0.gameID == id })
            let existing = try context.fetch(descriptor).first
            let saved = existing ?? SavedGame(game: game)
            if existing == nil { context.insert(saved) }
            if let status { saved.status = status }
            if toggleFavorite { saved.isFavorite.toggle() }
            let message = toggleFavorite ? (saved.isFavorite ? "Added to favorites" : "Removed from favorites") : "Saved to \(status?.title ?? "backlog")"
            if saved.status == nil && !saved.isFavorite && saved.personalRating == nil { context.delete(saved) }
            try context.save()
            feedback = message
        } catch {
            context.rollback()
            errorMessage = "Your change couldn't be saved. Please try again."
        }
    }
    func removeFromLibrary(_ saved: SavedGame, in context: ModelContext) {
        saved.status = nil
        if !saved.isFavorite && saved.personalRating == nil { context.delete(saved) }
        do {
            try context.save()
            feedback = "Removed from backlog"
        } catch {
            context.rollback()
            errorMessage = "The game couldn't be removed. Please try again."
        }
    }

    func setRating(_ rating: Int?, for game: Game, in context: ModelContext) {
        do {
            let id = game.id
            let descriptor = FetchDescriptor<SavedGame>(predicate: #Predicate { $0.gameID == id })
            let existing = try context.fetch(descriptor).first
            let saved = existing ?? SavedGame(game: game)
            if existing == nil { context.insert(saved) }
            saved.personalRating = rating
            if saved.status == nil && !saved.isFavorite && rating == nil { context.delete(saved) }
            try context.save()
            feedback = rating.map { "Rated \($0) out of 5" } ?? "Rating removed"
        } catch {
            context.rollback()
            errorMessage = "Your rating couldn't be saved. Please try again."
        }
    }
}
