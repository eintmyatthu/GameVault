import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \SavedGame.dateAdded, order: .reverse) private var savedGames: [SavedGame]
    @Environment(\.modelContext) private var context
    @State private var selectedStatus: LibraryStatus?
    @State private var model = LibraryViewModel()
    @State private var pendingRemoval: SavedGame?
    private var games: [SavedGame] {
        savedGames.filter { $0.status != nil && (selectedStatus == nil || $0.status == selectedStatus) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeading(eyebrow: "YOUR COLLECTION", title: "My Library", subtitle: "Every game has a place in your story.").padding(.horizontal, 20)
                ScrollView(.horizontal) {
                    HStack {
                        GenreChip(title: "All", isSelected: selectedStatus == nil) { withAnimation { selectedStatus = nil } }
                        ForEach(LibraryStatus.allCases) { status in
                            GenreChip(title: status.title, isSelected: selectedStatus == status) { withAnimation { selectedStatus = status } }
                        }
                    }.padding(.horizontal, 20)
                }.scrollIndicators(.hidden)
                if games.isEmpty {
                    EmptyStateView(symbol: "square.stack.3d.up", title: "\(selectedStatus?.title ?? "Your library") starts here", message: "Discover a game, open its details, and add it to a collection.")
                } else {
                    ForEach(LibraryStatus.allCases) { status in
                        let section = games.filter { $0.status == status }
                        if !section.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("\(status.title) · \(section.count)", systemImage: status.symbol).font(.headline)
                                LazyVStack(spacing: 12) {
                                    ForEach(section) { saved in
                                        LibraryGameRow(saved: saved, changeStatus: { newStatus in
                                            model.save(saved.game, status: newStatus, in: context)
                                        }, remove: { pendingRemoval = saved })
                                    }
                                }
                            }.padding(.horizontal, 20)
                        }
                    }
                }
            }.padding(.bottom, 24)
        }.background(VaultTheme.background).navigationTitle("Library").navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Remove \(pendingRemoval?.name ?? "game") from your library?", isPresented: Binding(get: { pendingRemoval != nil }, set: { if !$0 { pendingRemoval = nil } }), titleVisibility: .visible) {
                Button("Remove from Library", role: .destructive) {
                    if let saved = pendingRemoval { model.removeFromLibrary(saved, in: context) }
                    pendingRemoval = nil
                }
                Button("Cancel", role: .cancel) { pendingRemoval = nil }
            } message: { Text("If favorited, the game will remain in My Vault favorites.") }
            .alert("Couldn't save change", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) { model.errorMessage = nil }
            } message: { Text(model.errorMessage ?? "Please try again.") }
            .sensoryFeedback(.success, trigger: model.feedback)
    }
}
