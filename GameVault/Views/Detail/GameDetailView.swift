import SwiftUI
import SwiftData

struct GameDetailView: View {
    let game: Game
    @Environment(\.modelContext) private var context
    @Query private var savedGames: [SavedGame]
    @State private var model = GameDetailViewModel()
    @State private var library = LibraryViewModel()
    @State private var showingStatuses = false

    private var currentGame: Game { model.detail?.game ?? game }
    private var saved: SavedGame? { savedGames.first { $0.gameID == game.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                VStack(alignment: .leading, spacing: 24) {
                    actions
                    ratingControl
                    if let feedback = library.feedback {
                        Label(feedback, systemImage: "checkmark.circle.fill")
                            .font(.subheadline.bold()).foregroundStyle(VaultTheme.accent)
                    }
                    if model.isLoading { LoadingView(title: "Loading game details…") }
                    if let error = model.errorMessage {
                        ErrorView(message: error) { Task { await model.load(id: game.id) } }
                    }
                    metadata
                    if let screenshots = model.detail?.screenshots, !screenshots.isEmpty {
                        screenshotCarousel(screenshots)
                    }
                    Text("About the game").font(.title2.bold())
                    Text(nonempty(model.detail?.description) ?? nonempty(currentGame.shortDescription) ?? "No description is available for this game.")
                        .foregroundStyle(.secondary).textSelection(.enabled)
                    if let value = model.detail?.minimumSystemRequirements { requirements(value) }
                    if let address = model.detail?.gameURL ?? currentGame.gameURL,
                       let url = URL(string: address), ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
                        Link(destination: url) { Label("Play on the official site", systemImage: "arrow.up.right.square") }
                            .buttonStyle(.borderedProminent).controlSize(.large)
                    }
                    Link("Game data & artwork by FreeToGame", destination: URL(string: "https://www.freetogame.com")!)
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(.horizontal, 20)
            }.padding(.bottom, 30)
        }
        .background(VaultTheme.background)
        .navigationTitle(currentGame.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: game.id) { await model.load(id: game.id) }
        .confirmationDialog("Save \(currentGame.name) as…", isPresented: $showingStatuses, titleVisibility: .visible) {
            ForEach(LibraryStatus.allCases) { status in
                Button(status.title) { library.save(currentGame, status: status, in: context) }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Couldn't save change", isPresented: Binding(get: { library.errorMessage != nil }, set: { if !$0 { library.errorMessage = nil } })) {
            Button("OK", role: .cancel) { library.errorMessage = nil }
        } message: { Text(library.errorMessage ?? "Please try again.") }
        .sensoryFeedback(.success, trigger: library.feedback)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            GameArtwork(url: currentGame.backgroundImage)
            LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 10) {
                Text("FREE TO PLAY").font(.caption.weight(.heavy)).tracking(3).foregroundStyle(.white.opacity(0.8))
                Text(currentGame.name).font(.largeTitle.bold()).foregroundStyle(.white)
                Label(currentGame.genre ?? "Game", systemImage: "tag.fill").foregroundStyle(.white)
            }.padding(24)
        }.frame(minHeight: 340).clipped()
    }

    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { statusButton; favoriteButton }
            VStack(alignment: .leading, spacing: 12) { statusButton; favoriteButton }
        }
    }

    private var statusButton: some View {
        Button { showingStatuses = true } label: {
            Label(saved?.status?.title ?? "Add to Backlog", systemImage: saved?.status?.symbol ?? "plus")
                .font(.headline).padding(.vertical, 8)
        }.buttonStyle(.borderedProminent).controlSize(.large)
    }

    private var favoriteButton: some View {
        Button { withAnimation(.snappy) { library.save(currentGame, toggleFavorite: true, in: context) } } label: {
            Label(saved?.isFavorite == true ? "Favorited" : "Favorite", systemImage: saved?.isFavorite == true ? "heart.fill" : "heart")
                .contentTransition(.symbolEffect(.replace)).padding(.vertical, 8)
        }.buttonStyle(.bordered).controlSize(.large)
    }

    private var ratingControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Your rating").font(.headline); Spacer(); Text(saved?.personalRating.map { "\($0)/5" } ?? "Not rated").foregroundStyle(.secondary) }
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { value in
                    Button { library.setRating(saved?.personalRating == value ? nil : value, for: currentGame, in: context) } label: {
                        Image(systemName: value <= (saved?.personalRating ?? 0) ? "star.fill" : "star")
                            .font(.title2).foregroundStyle(.yellow).frame(minWidth: 36, minHeight: 44)
                    }.buttonStyle(.plain).accessibilityLabel("Rate \(value) out of 5")
                }
            }
        }.padding(20).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game overview").font(.title2.bold())
            fact("Genre", value: currentGame.genre)
            fact("Platform", value: currentGame.platform)
            fact("Release date", value: currentGame.releaseDate)
            fact("Developer", value: model.detail?.developer ?? currentGame.developer)
            fact("Publisher", value: model.detail?.publisher ?? currentGame.publisher)
            fact("Status", value: model.detail?.status)
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private func screenshotCarousel(_ screenshots: [GameScreenshot]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Screenshots").font(.title2.bold())
            TabView {
                ForEach(screenshots) { screenshot in
                    GameArtwork(url: screenshot.image).clipShape(RoundedRectangle(cornerRadius: 20)).padding(.horizontal, 2)
                }
            }.frame(height: 230).tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }

    private func requirements(_ requirements: MinimumSystemRequirements) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Minimum system requirements").font(.title2.bold())
            fact("Operating system", value: requirements.os)
            fact("Processor", value: requirements.processor)
            fact("Memory", value: requirements.memory)
            fact("Graphics", value: requirements.graphics)
            fact("Storage", value: requirements.storage)
        }.padding(20).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private func fact(_ label: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.caption.weight(.semibold)).tracking(1).foregroundStyle(.secondary)
            Text(nonempty(value) ?? "Not available").font(.subheadline)
        }
    }

    private func nonempty(_ text: String?) -> String? {
        guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return text
    }
}
