import SwiftUI

struct LoadingView: View {
    var title = "Loading games…"
    var body: some View {
        VStack(spacing: 14) { ProgressView(); Text(title).font(.subheadline).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity).padding(36)
    }
}
struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark").font(.largeTitle).foregroundStyle(VaultTheme.accent)
            Text("Let's try that again").font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Retry", action: retry).buttonStyle(.borderedProminent).controlSize(.large)
        }.padding(28).frame(maxWidth: .infinity).background(VaultTheme.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}
struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
    }
}
