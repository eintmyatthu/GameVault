import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \SavedGame.dateAdded, order: .reverse) private var games: [SavedGame]
    @AppStorage("profile.playerName") private var playerName = "Mi Hsu"
    @State private var showingSettings = false
    @State private var showingAbout = false

    private var libraryGames: [SavedGame] { games.filter { $0.status != nil } }
    private var favorites: [SavedGame] { games.filter(\.isFavorite) }
    private var level: Int { max(1, libraryGames.count / 5 + 1) }

    private var genreStats: [(name: String, count: Int)] {
        let names = libraryGames.flatMap { Array(Set($0.genreNames)) }
        return Dictionary(grouping: names, by: { $0 })
            .map { (name: $0.key, count: $0.value.count) }
            .sorted { $0.count == $1.count ? $0.name < $1.name : $0.count > $1.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                profileHeader
                statStrip
                favoriteGenres
                profileLinks
            }
            .padding(20)
        }
        .background(VaultTheme.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSettings) {
            ProfileSettingsView(playerName: $playerName)
        }
        .sheet(isPresented: $showingAbout) {
            AboutEHMGameShelfView()
        }
        .task {
            if playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || playerName == "Player One" {
                playerName = "Mi Hsu"
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(VaultTheme.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(playerName.isEmpty ? "Mi Hsu" : playerName)
                    .font(.title.bold())
                Text("Level \(level)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile settings")
        }
    }

    private var statStrip: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            profileStat(title: "Games", count: libraryGames.count, symbol: "gamecontroller.fill")
            profileStat(title: "Favorites", count: favorites.count, symbol: "heart.fill")
            profileStat(title: "Wishlist", count: games.filter { $0.status == .wantToPlay }.count, symbol: "bookmark.fill")
            profileStat(title: "Playing", count: games.filter { $0.status == .playing }.count, symbol: "play.circle.fill")
        }
        .padding(14)
        .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 22))
    }

    private var favoriteGenres: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Favorite Genres")
                .font(.title2.bold())

            if genreStats.isEmpty {
                ContentUnavailableView {
                    Label("No genres yet", systemImage: "chart.bar")
                } description: {
                    Text("Add games to your library to reveal your favorite genres.")
                }
                .frame(maxWidth: .infinity)
            } else {
                ForEach(genreStats.prefix(4), id: \.name) { genre in
                    let fraction = Double(genre.count) / Double(max(libraryGames.count, 1))
                    VStack(spacing: 8) {
                        HStack {
                            Text(genre.name).font(.headline)
                            Spacer()
                            Text(fraction, format: .percent.precision(.fractionLength(0)))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: fraction)
                            .tint(VaultTheme.accent)
                            .scaleEffect(y: 1.6)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .padding(20)
        .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 22))
    }

    private var profileLinks: some View {
        VStack(spacing: 0) {
            profileRow(title: "Settings", symbol: "gearshape") { showingSettings = true }
            Divider().padding(.leading, 56)
            profileRow(title: "EHM GameShelf", symbol: "info.circle") { showingAbout = true }
            Divider().padding(.leading, 56)
            Link(destination: URL(string: "https://www.freetogame.com")!) {
                rowLabel(title: "Data source: FreeToGame", symbol: "network")
            }
            .buttonStyle(.plain)
        }
        .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 22))
    }

    private func profileStat(title: String, count: Int, symbol: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(VaultTheme.accent)
            Text(count.formatted())
                .font(.title3.bold().monospacedDigit())
                .contentTransition(.numericText())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .top)
        .accessibilityElement(children: .combine)
    }

    private func profileRow(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowLabel(title: title, symbol: symbol)
        }
        .buttonStyle(.plain)
    }

    private func rowLabel(title: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(VaultTheme.accent)
                .frame(width: 28)
            Text(title).font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
        .frame(minHeight: 58)
    }
}

private struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var playerName: String

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Display name", text: $playerName)
                        .textInputAutocapitalization(.words)
                        .onChange(of: playerName) { _, value in
                            if value.count > 24 { playerName = String(value.prefix(24)) }
                        }
                } header: {
                    Text("Player")
                } footer: {
                    Text("Your profile name is stored only on this device.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        playerName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct AboutEHMGameShelfView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(VaultTheme.accent)
                Text("EHM GameShelf")
                    .font(.largeTitle.bold())
                Text("Discover free-to-play games, build a personal library, and see your tastes take shape.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Text("Your library and profile stay on this device. No account is required.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(28)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
