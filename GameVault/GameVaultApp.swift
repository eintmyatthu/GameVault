import SwiftUI
import SwiftData

@main
struct EHMGameShelfApp: App {
    @State private var container: ModelContainer?
    @State private var storageError: String?
    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    ContentView().modelContainer(container)
                } else if let storageError {
                    ErrorView(message: storageError, retry: openStorage).padding()
                } else {
                    LoadingView(title: "Opening your vault…")
                }
            }.task { if container == nil { openStorage() } }
        }
    }
    private func openStorage() {
        do {
            container = try ModelContainer(for: SavedGame.self)
            storageError = nil
        } catch {
            // Never replace a failed persistent store with a silently empty in-memory one.
            storageError = "Your saved vault couldn't be opened. Please retry or restart the app."
        }
    }
}
