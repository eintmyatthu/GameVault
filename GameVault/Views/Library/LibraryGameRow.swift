import SwiftUI

struct LibraryGameRow: View {
    let saved: SavedGame
    let changeStatus: (LibraryStatus) -> Void
    let remove: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(value: saved.game) { SearchResultRow(game: saved.game) }.buttonStyle(.plain)
            HStack {
                Label(saved.status?.title ?? "Favorite", systemImage: saved.status?.symbol ?? "heart.fill")
                    .font(.caption.bold()).foregroundStyle(VaultTheme.accent)
                if saved.isFavorite { Image(systemName: "heart.fill").foregroundStyle(.pink).accessibilityLabel("Favorite") }
                Spacer()
                Menu {
                    ForEach(LibraryStatus.allCases) { status in
                        Button(status.title, systemImage: status.symbol) { changeStatus(status) }
                    }
                    Divider()
                    Button("Remove from Library", systemImage: "trash", role: .destructive, action: remove)
                } label: {
                    Image(systemName: "ellipsis").frame(width: 44, height: 44).contentShape(Rectangle())
                }.accessibilityLabel("Manage \(saved.name)")
            }.padding(.horizontal, 16)
        }.background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 22))
    }
}
