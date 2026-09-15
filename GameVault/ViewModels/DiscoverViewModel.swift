import Foundation
import Observation

@MainActor @Observable
final class DiscoverViewModel {
    var popular: [Game] = []
    var newest: [Game] = []
    var alphabetical: [Game] = []
    let genres = GameCategory.common
    var isLoading = false
    var errorMessage: String?
    private let service = FreeToGameService()

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let popularResult = service.games(sort: .popularity)
            async let newestResult = service.games(sort: .releaseDate)
            async let alphabeticalResult = service.games(sort: .alphabetical)
            let result = try await (popularResult, newestResult, alphabeticalResult)
            try Task.checkCancellation()
            popular = Array(result.0.prefix(15))
            newest = Array(result.1.prefix(15))
            alphabetical = Array(result.2.prefix(15))
        } catch is CancellationError {
        } catch { errorMessage = error.localizedDescription }
    }
}
