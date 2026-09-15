import Foundation
import Observation

@MainActor @Observable
final class GameDetailViewModel {
    var detail: GameDetail?
    var isLoading = false
    var errorMessage: String?
    func load(id: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do { detail = try await FreeToGameService().detail(id: id) }
        catch is CancellationError { }
        catch { errorMessage = error.localizedDescription }
    }
}
