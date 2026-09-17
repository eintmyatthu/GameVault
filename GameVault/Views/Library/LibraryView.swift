import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \SavedGame.dateAdded, order: .reverse) private var savedGames: [SavedGame]
    @Environment(\.modelContext) private var context
    @State private var selectedStatus: LibraryStatus?
    @State private var model = LibraryViewModel()
    @State private var pendingRemoval: SavedGame?
    @State private var showingPicker = false
    @State private var pickedGame: SavedGame?
    private var games: [SavedGame] {
        savedGames.filter { $0.status != nil && (selectedStatus == nil || $0.status == selectedStatus) }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeading(eyebrow: "YOUR COLLECTION", title: "My Library", subtitle: "Track games on your wishlist, games you are playing, or games you have completed.").padding(.horizontal, 20)
                Button {
                    pickedGame = savedGames.filter { $0.status == .wantToPlay }.randomElement()
                    showingPicker = true
                } label: {
                    Label("Pick Tonight’s Game", systemImage: "dice.fill").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent).controlSize(.large)
                    .disabled(!savedGames.contains { $0.status == .wantToPlay })
                    .padding(.horizontal, 20)
                ScrollView(.horizontal) {
                    HStack {
                        GenreChip(title: "All", isSelected: selectedStatus == nil) { withAnimation { selectedStatus = nil } }
                        ForEach(LibraryStatus.allCases) { status in
                            GenreChip(title: status.title, isSelected: selectedStatus == status) { withAnimation { selectedStatus = status } }
                        }
                    }.padding(.horizontal, 20)
                }.scrollIndicators(.hidden)
                if games.isEmpty {
                    EmptyStateView(symbol: "square.stack.3d.up", title: "\(selectedStatus?.title ?? "Your library") starts here", message: "Discover a game, open its details, and add it to your library.")
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
            } message: { Text("Its personal rating and favorite status will be preserved.") }
            .alert("Couldn't save change", isPresented: Binding(get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })) {
                Button("OK", role: .cancel) { model.errorMessage = nil }
            } message: { Text(model.errorMessage ?? "Please try again.") }
            .sensoryFeedback(.success, trigger: model.feedback)
            .sheet(isPresented: $showingPicker) {
                TonightPickerView(game: $pickedGame,
                                  candidates: savedGames.filter { $0.status == .wantToPlay },
                                  startPlaying: { saved in
                                      model.save(saved.game, status: .playing, in: context)
                                      showingPicker = false
                                  })
            }
    }
}

private struct TonightPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var game: SavedGame?
    let candidates: [SavedGame]
    let startPlaying: (SavedGame) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Text("TONIGHT’S PICK").font(.caption.bold()).tracking(3).foregroundStyle(VaultTheme.accent)
                if let game {
                    GameArtwork(url: game.imageURL).frame(height: 260).clipShape(RoundedRectangle(cornerRadius: 24))
                    Text(game.name).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text(game.genreNames.first ?? game.platformNames.first ?? "Free-to-play").foregroundStyle(.secondary)
                    NavigationLink { GameDetailView(game: game.game) } label: {
                        Label("View Details", systemImage: "info.circle").frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                    Button { startPlaying(game) } label: {
                        Label("Start Playing", systemImage: "gamecontroller.fill").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    Button { pickAgain() } label: { Label("Choose Again", systemImage: "arrow.clockwise") }
                        .disabled(candidates.count < 2)
                } else {
                    EmptyStateView(symbol: "dice", title: "Nothing to pick yet", message: "Add a game to your Wishlist first.")
                }
                Spacer()
            }.padding(24).navigationTitle("Pick a Game").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    private func pickAgain() {
        let alternatives = candidates.filter { $0.gameID != game?.gameID }
        game = alternatives.randomElement() ?? candidates.randomElement()
    }
}
