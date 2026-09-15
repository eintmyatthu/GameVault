import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DiscoverView().navigationDestination(for: Game.self) { GameDetailView(game: $0) }
            }.tabItem { Label("Discover", systemImage: "sparkles") }
            NavigationStack {
                SearchView().navigationDestination(for: Game.self) { GameDetailView(game: $0) }
            }.tabItem { Label("Search", systemImage: "magnifyingglass") }
            NavigationStack {
                LibraryView().navigationDestination(for: Game.self) { GameDetailView(game: $0) }
            }.tabItem { Label("Backlog", systemImage: "square.stack.3d.up") }
            NavigationStack {
                JournalView().navigationDestination(for: Game.self) { GameDetailView(game: $0) }
            }.tabItem { Label("Journal", systemImage: "book.closed") }
        }.tint(VaultTheme.accent)
    }
}
