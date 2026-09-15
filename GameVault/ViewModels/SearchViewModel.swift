import Foundation
import Observation

@MainActor @Observable
final class SearchViewModel {
    var query = ""
    var selectedGenre: String?
    var selectedPlatform: GamePlatformFilter = .all
    var selectedSort: GameSort = .relevance
    let genres = GameCategory.common
    var games: [Game] = []
    var isLoading = false
    var hasSearched = false
    var errorMessage: String?
    private var requestID = UUID()
    private let service = FreeToGameService()

    var searchIdentity: String {
        "\(query)|\(selectedGenre ?? "")|\(selectedPlatform.rawValue)|\(selectedSort.rawValue)"
    }

    func search() async {
        let id = UUID()
        requestID = id
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil
        hasSearched = !text.isEmpty || selectedGenre != nil || selectedPlatform != .all
        isLoading = true
        defer { if requestID == id { isLoading = false } }
        do {
            try await Task.sleep(for: .milliseconds(300))
            let result = try await service.games(platform: selectedPlatform.apiValue,
                                                   category: selectedGenre,
                                                   sort: selectedSort)
            try Task.checkCancellation()
            guard requestID == id else { return }
            games = text.isEmpty ? result : result.filter { $0.title.localizedCaseInsensitiveContains(text) }
        } catch is CancellationError {
        } catch {
            if requestID == id { errorMessage = error.localizedDescription }
        }
    }
}
