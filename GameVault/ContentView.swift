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
            }.tabItem { Label("Library", systemImage: "square.stack.3d.up") }
            NavigationStack {
                VaultView().navigationDestination(for: Game.self) { GameDetailView(game: $0) }
            }.tabItem { Label("My Vault", systemImage: "person.crop.circle") }
        }.tint(VaultTheme.accent)
    }
}
