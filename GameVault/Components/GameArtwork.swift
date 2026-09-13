import SwiftUI

struct GameArtwork: View {
    let url: String?
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: url.flatMap(URL.init(string:))) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    placeholder.overlay { if url != nil { ProgressView().tint(.white) } }
                default: placeholder
                }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }.accessibilityHidden(true)
    }
    private var placeholder: some View {
        LinearGradient(colors: [VaultTheme.accent.opacity(0.35), .indigo.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay { Image(systemName: "gamecontroller.fill").font(.largeTitle).foregroundStyle(.secondary) }
    }
}
