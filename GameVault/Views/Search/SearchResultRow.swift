import SwiftUI

struct SearchResultRow: View {
    let game: Game
    var body: some View {
        HStack(spacing: 14) {
            GameArtwork(url: game.backgroundImage).frame(width: 88, height: 94).clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 7) {
                Text(game.name).font(.headline).lineLimit(2)
                Label(game.genre ?? "Free-to-play", systemImage: "tag.fill").font(.caption.bold()).foregroundStyle(VaultTheme.accent)
                Text(game.platformNames).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
        }.padding(12).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 22))
            .accessibilityElement(children: .combine)
    }
}
