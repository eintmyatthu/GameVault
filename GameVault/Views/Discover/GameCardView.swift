import SwiftUI

struct GameCardView: View {
    let game: Game
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GameArtwork(url: game.backgroundImage).frame(height: 145).clipShape(RoundedRectangle(cornerRadius: 16))
            Text(game.name).font(.headline).lineLimit(2).frame(height: 46, alignment: .topLeading)
            Label(game.ratingText, systemImage: "star.fill").font(.caption.bold()).foregroundStyle(.orange)
            Text(game.platformNames).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }.padding(12).frame(width: 220).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
            .accessibilityElement(children: .combine)
    }
}
struct GameSectionView: View {
    let title: String
    let games: [Game]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2.bold()).padding(.horizontal, 20)
            if games.isEmpty {
                Text("No games available yet.").foregroundStyle(.secondary).padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 14) {
                        ForEach(games) { game in
                            NavigationLink(value: game) { GameCardView(game: game) }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 20)
                }.scrollIndicators(.hidden)
            }
        }
    }
}
