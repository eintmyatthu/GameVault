import Foundation
import Observation

@MainActor @Observable
final class SearchViewModel {
    var query = ""
    var selectedGenre: String?
    var genres: [NamedResource] = []
    var games: [Game] = []
    var isLoading = false
    var hasSearched = false
    var errorMessage: String?
    var hasMore = false
    private var page = 1
    private var requestID = UUID()
    private let service = RAWGService()
    var searchIdentity: String { "\(query)|\(selectedGenre ?? "")" }

    func loadGenres() async {
        do { genres = try await service.genres() }
        catch { /* Search still works when genre loading fails. */ }
    }
    func search(loadMore: Bool = false) async {
        let id = UUID()
        requestID = id
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !loadMore {
            games = []
            page = 1
            hasMore = false
        }
        errorMessage = nil
        guard !text.isEmpty || selectedGenre != nil else {
            hasSearched = false
            isLoading = false
            return
        }
        isLoading = true
        hasSearched = true
        defer { if requestID == id { isLoading = false } }
        do {
            if !loadMore { try await Task.sleep(for: .milliseconds(450)) }
            let nextPage = loadMore ? page + 1 : 1
            let result = try await service.searchGames(text: text, genre: selectedGenre, page: nextPage)
            try Task.checkCancellation()
            guard requestID == id else { return }
            let existingIDs = Set(games.map(\.id))
            games += result.results.filter { !existingIDs.contains($0.id) }
            page = nextPage
            hasMore = result.next != nil
        } catch is CancellationError {
        } catch {
            if requestID == id { errorMessage = error.localizedDescription }
        }
    }
}
