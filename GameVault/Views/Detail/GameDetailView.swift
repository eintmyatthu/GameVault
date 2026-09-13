import SwiftUI
import SwiftData

struct GameDetailView: View {
    let game: Game
    @Environment(\.modelContext) private var context
    @Query private var savedGames: [SavedGame]
    @State private var model = GameDetailViewModel()
    @State private var library = LibraryViewModel()
    @State private var showingCollections = false
    private var currentGame: Game { model.detail?.game ?? game }
    private var saved: SavedGame? { savedGames.first { $0.rawgID == game.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                VStack(alignment: .leading, spacing: 24) {
                    actions
                    if let feedback = library.feedback {
                        Label(feedback, systemImage: "checkmark.circle.fill")
                            .font(.subheadline.bold()).foregroundStyle(VaultTheme.accent)
                            .transition(.opacity).accessibilityLabel(feedback)
                    }
                    if model.isLoading { LoadingView(title: "Loading game details…") }
                    if let error = model.errorMessage {
                        ErrorView(message: error) { Task { await model.load(id: game.id) } }
                    }
                    metadata
                    if let detail = model.detail {
                        Text("About the game").font(.title2.bold())
                        Text(nonempty(detail.descriptionRaw) ?? "No description is available for this game.")
                            .font(.body).foregroundStyle(.secondary).textSelection(.enabled)
                        if let website = detail.website, let url = URL(string: website), ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
                            Link(destination: url) { Label("Official website", systemImage: "arrow.up.right.square") }
                                .frame(minHeight: 44)
                        }
                    }
                    Link("Game data & artwork by RAWG", destination: URL(string: "https://rawg.io")!)
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(.horizontal, 20)
            }.padding(.bottom, 30)
        }.background(VaultTheme.background)
            .navigationTitle(currentGame.name).navigationBarTitleDisplayMode(.inline)
            .task(id: game.id) { await model.load(id: game.id) }
            .confirmationDialog("Add \(currentGame.name) to…", isPresented: $showingCollections, titleVisibility: .visible) {
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
            VStack(alignment: .leading, spacing: 12) {
                Text("THE NEXT CHAPTER").font(.caption.weight(.heavy)).tracking(3).foregroundStyle(.white.opacity(0.8))
                Text(currentGame.name).font(.largeTitle.bold()).foregroundStyle(.white)
                HStack(spacing: 18) {
                    Label(currentGame.ratingText, systemImage: "star.fill").foregroundStyle(.yellow)
                    if let score = currentGame.metacritic {
                        Text("\(score) Metacritic").foregroundStyle(.mint)
                    }
                }.font(.subheadline.bold())
            }.padding(24)
        }.frame(minHeight: 340).clipped()
    }
    private var actions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { collectionButton; favoriteButton }
            VStack(alignment: .leading, spacing: 12) { collectionButton; favoriteButton }
        }
    }
    private var collectionButton: some View {
        Button { showingCollections = true } label: {
            Label(saved?.status?.title ?? "Add to Library", systemImage: saved?.status?.symbol ?? "plus")
                .font(.headline).padding(.vertical, 8)
        }.buttonStyle(.borderedProminent).controlSize(.large)
    }
    private var favoriteButton: some View {
        Button {
            withAnimation(.snappy) { library.save(currentGame, toggleFavorite: true, in: context) }
        } label: {
            Label(saved?.isFavorite == true ? "Favorited" : "Favorite", systemImage: saved?.isFavorite == true ? "heart.fill" : "heart")
                .contentTransition(.symbolEffect(.replace)).padding(.vertical, 8)
        }.buttonStyle(.bordered).controlSize(.large)
            .accessibilityLabel(saved?.isFavorite == true ? "Remove from favorites" : "Add to favorites")
    }
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Game overview").font(.title2.bold())
            fact("Genres", value: currentGame.genres?.map(\.name).joined(separator: " · "))
            fact("Platforms", value: currentGame.platformNames)
            fact("Release date", value: currentGame.released)
            if let detail = model.detail {
                fact("Developer", value: detail.developers?.map(\.name).joined(separator: ", "))
                fact("Publisher", value: detail.publishers?.map(\.name).joined(separator: ", "))
                fact("Age rating", value: detail.esrbRating?.name)
            }
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
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
