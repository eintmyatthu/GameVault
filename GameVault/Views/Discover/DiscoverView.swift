import SwiftUI

struct DiscoverView: View {
    @State private var model = DiscoverViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "EHM GAMESHELF", title: "Find your next\nadventure.", subtitle: "Free-to-play games. One place to keep them.")
                    .padding(.horizontal, 20)
                if model.isLoading && model.popular.isEmpty { LoadingView() }
                if let error = model.errorMessage {
                    ErrorView(message: error) { Task { await model.load() } }.padding(.horizontal, 20)
                }
                if !model.popular.isEmpty || (!model.isLoading && model.errorMessage == nil) {
                    GameSectionView(title: "🔥 Popular Games", games: model.popular)
                    GameSectionView(title: "🆕 New Releases", games: model.newest)
                    GameSectionView(title: "🔤 Browse A–Z", games: model.alphabetical)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🎮 Browse by Genre").font(.title2.bold())
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                            ForEach(model.genres) { genre in
                                NavigationLink {
                                    SearchView(initialGenre: genre)
                                } label: {
                                    Text(genre.name).font(.subheadline.bold()).frame(maxWidth: .infinity, minHeight: 58)
                                        .background(VaultTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                                }.buttonStyle(.plain)
                            }
                        }
                    }.padding(.horizontal, 20)
                }
                Link("Game data & artwork by FreeToGame", destination: URL(string: "https://www.freetogame.com")!)
                    .font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
            }.padding(.bottom, 24)
        }.background(VaultTheme.background).navigationTitle("Discover").navigationBarTitleDisplayMode(.inline)
            .task { if model.popular.isEmpty { await model.load() } }
            .refreshable { await model.load() }
    }
}
