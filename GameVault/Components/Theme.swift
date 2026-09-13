import SwiftUI

enum VaultTheme {
    static let accent = Color(red: 0.64, green: 0.46, blue: 1)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
}

struct PageHeading: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow).font(.caption.weight(.heavy)).tracking(3).foregroundStyle(VaultTheme.accent)
            Text(title).font(.largeTitle.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
    }
}

struct GenreChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.subheadline.weight(.semibold))
                .padding(.horizontal, 18).frame(minHeight: 44)
                .background(isSelected ? VaultTheme.accent : VaultTheme.surface, in: Capsule())
                .foregroundStyle(isSelected ? Color.black : Color.primary)
        }.buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
