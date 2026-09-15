import SwiftUI
import SwiftData

struct VaultView: View {
    @Query(sort: \SavedGame.dateAdded, order: .reverse) private var games: [SavedGame]
    private var collected: [SavedGame] { games.filter { $0.status != nil } }
    private var favorites: [SavedGame] { games.filter(\.isFavorite) }
    private var genreStats: [(name: String, count: Int)] {
        let names = games.flatMap { Array(Set($0.genreNames)) }
        return Dictionary(grouping: names, by: { $0 }).map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.count == $1.count ? $0.name < $1.name : $0.count > $1.count }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                PageHeading(eyebrow: "PLAYER PROFILE", title: "My Vault", subtitle: "A little more you. One game at a time.")
                VStack(alignment: .leading, spacing: 12) {
                    Label("GAMES COLLECTED", systemImage: "square.stack.3d.up.fill").font(.caption.bold()).tracking(2)
                    Text(collected.count.formatted()).font(.system(size: 64, weight: .bold, design: .rounded))
                    Text("Your adventures, all together.").font(.subheadline)
                }.foregroundStyle(.white).padding(26).frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [.indigo, VaultTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 28))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 14) {
                    stat("Favorites", count: favorites.count, symbol: "heart.fill", color: .pink)
                    ForEach(LibraryStatus.allCases) { status in
                        stat(status.title, count: collected.filter { $0.status == status }.count, symbol: status.symbol, color: VaultTheme.accent)
                    }
                }
                Text("Favorite Genres").font(.title2.bold())
                if genreStats.isEmpty {
                    Text("Save games to discover your most collected genres.").foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Share of saved games · games may have multiple genres").font(.caption).foregroundStyle(.secondary)
                        ForEach(genreStats.prefix(5), id: \.name) { genre in
                            let fraction = Double(genre.count) / Double(max(games.count, 1))
                            VStack(spacing: 8) {
                                HStack { Text(genre.name); Spacer(); Text(fraction, format: .percent.precision(.fractionLength(0))).foregroundStyle(.secondary) }
                                ProgressView(value: fraction).tint(VaultTheme.accent)
                            }.font(.subheadline)
                        }
                    }.padding(20).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
                }
                Text("Your favorites").font(.title2.bold())
                if favorites.isEmpty {
                    Text("Tap the heart on a game to keep it close.").foregroundStyle(.secondary)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(favorites) { saved in
                            NavigationLink(value: saved.game) { SearchResultRow(game: saved.game) }.buttonStyle(.plain)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Label("About EHMGameShelf", systemImage: "gamecontroller.fill").font(.headline)
                    Text("Discover free-to-play adventures and build a backlog that's yours. Built with SwiftUI and SwiftData for an iOS final project.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("Your collection stays on this device. No account required.").font(.caption).foregroundStyle(.secondary)
                    Link("Powered by FreeToGame ↗", destination: URL(string: "https://www.freetogame.com")!).font(.subheadline.bold()).frame(minHeight: 44)
                }.padding(20).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
            }.padding(20)
        }.background(VaultTheme.background).navigationTitle("My Vault").navigationBarTitleDisplayMode(.inline)
    }
    private func stat(_ title: String, count: Int, symbol: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).foregroundStyle(color).font(.title2)
            Text(count.formatted()).font(.title.bold()).contentTransition(.numericText())
            Text(title).font(.subheadline).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
            .accessibilityElement(children: .combine)
    }
}
