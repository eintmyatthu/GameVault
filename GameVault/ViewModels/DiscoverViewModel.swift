import Foundation
import Observation

@MainActor @Observable
final class DiscoverViewModel {
    var popular: [Game] = []
    var topRated: [Game] = []
    var recent: [Game] = []
    var genres: [NamedResource] = []
    var isLoading = false
    var errorMessage: String?
    private let service = RAWGService()

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let popularResult = service.popularGames()
            async let topResult = service.topRatedGames()
            async let recentResult = service.recentGames()
            async let genreResult = service.genres()
            let result = try await (popularResult, topResult, recentResult, genreResult)
            try Task.checkCancellation()
            (popular, topRated, recent, genres) = result
        } catch is CancellationError {
        } catch { errorMessage = error.localizedDescription }
    }
}
