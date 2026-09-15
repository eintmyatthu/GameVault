import SwiftUI

struct SearchView: View {
    @State private var model = SearchViewModel()
    var initialGenre: GameCategory?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeading(eyebrow: "EXPLORE", title: "Search free games", subtitle: "Filter by genre and platform, then choose your order.")
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Platform").font(.headline)
                    Picker("Platform", selection: $model.selectedPlatform) {
                        ForEach(GamePlatformFilter.allCases) { Text($0.title).tag($0) }
                    }.pickerStyle(.segmented)
                }.padding(.horizontal, 20)

                ScrollView(.horizontal) {
                    HStack {
                        GenreChip(title: "All genres", isSelected: model.selectedGenre == nil) { model.selectedGenre = nil }
                        ForEach(model.genres) { genre in
                            GenreChip(title: genre.name, isSelected: model.selectedGenre == genre.id) {
                                model.selectedGenre = genre.id
                            }
                        }
                    }.padding(.horizontal, 20)
                }.scrollIndicators(.hidden)

                HStack {
                    Text("Sort by").font(.headline)
                    Spacer()
                    Picker("Sort by", selection: $model.selectedSort) {
                        ForEach(GameSort.allCases) { Text($0.title).tag($0) }
                    }.pickerStyle(.menu)
                }.padding(.horizontal, 20)

                if model.isLoading { LoadingView(title: "Searching FreeToGame…") }
                if let error = model.errorMessage {
                    ErrorView(message: error) { Task { await model.search() } }.padding(.horizontal, 20)
                }
                LazyVStack(spacing: 12) {
                    ForEach(model.games) { game in
                        NavigationLink(value: game) { SearchResultRow(game: game) }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 20)
                if !model.isLoading && model.errorMessage == nil && model.games.isEmpty {
                    EmptyStateView(symbol: "magnifyingglass", title: model.hasSearched ? "No games found" : "What will you play next?", message: model.hasSearched ? "Try another title or change a filter." : "Search by title or explore the filters.")
                }
            }.padding(.bottom, 24)
        }
        .background(VaultTheme.background)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.query, prompt: "Search game titles")
        .task {
            if let initialGenre { model.selectedGenre = initialGenre.id }
        }
        .task(id: model.searchIdentity) { await model.search() }
    }
}
