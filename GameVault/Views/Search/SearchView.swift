import SwiftUI

struct SearchView: View {
    @State private var model = SearchViewModel()
    var initialGenre: NamedResource?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeading(eyebrow: "EXPLORE", title: "Search games", subtitle: "Your next favorite is out there.").padding(.horizontal, 20)
                ScrollView(.horizontal) {
                    HStack {
                        GenreChip(title: "All genres", isSelected: model.selectedGenre == nil) { model.selectedGenre = nil }
                        ForEach(model.genres) { genre in
                            GenreChip(title: genre.name, isSelected: model.selectedGenre == (genre.slug ?? String(genre.id))) {
                                model.selectedGenre = genre.slug ?? String(genre.id)
                            }
                        }
                    }.padding(.horizontal, 20)
                }.scrollIndicators(.hidden)
                if model.isLoading { LoadingView(title: "Searching RAWG…") }
                if let error = model.errorMessage {
                    ErrorView(message: error) { Task { await model.search(loadMore: !model.games.isEmpty) } }.padding(.horizontal, 20)
                }
                LazyVStack(spacing: 12) {
                    ForEach(model.games) { game in
                        NavigationLink(value: game) { SearchResultRow(game: game) }.buttonStyle(.plain)
                    }
                    if model.hasMore && !model.isLoading {
                        Button("Load more games") { Task { await model.search(loadMore: true) } }
                            .buttonStyle(.bordered).controlSize(.large)
                    }
                }.padding(.horizontal, 20)
                if !model.isLoading && model.errorMessage == nil && model.games.isEmpty {
                    EmptyStateView(symbol: "magnifyingglass", title: model.hasSearched ? "No games found" : "What will you play next?", message: model.hasSearched ? "Try a different title or change the genre filter." : "Search for a title, or select a genre to start exploring.")
                }
            }.padding(.bottom, 24)
        }.background(VaultTheme.background).navigationTitle("Search").navigationBarTitleDisplayMode(.inline)
            .searchable(text: $model.query, prompt: "Games, adventures, new favorites")
            .task {
                if let initialGenre { model.selectedGenre = initialGenre.slug ?? String(initialGenre.id) }
                await model.loadGenres()
            }
            .task(id: model.searchIdentity) { await model.search() }
    }
}
