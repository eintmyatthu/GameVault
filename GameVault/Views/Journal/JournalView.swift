import SwiftUI
import SwiftData

private struct JournalDraft: Identifiable {
    let id = UUID()
    var entryID: UUID?
    var gameID: Int
    var gameName: String
    var date: Date
    var text: String
}

struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query(sort: \SavedGame.name) private var savedGames: [SavedGame]
    @State private var draft: JournalDraft?
    @State private var errorMessage: String?

    private var availableGames: [SavedGame] { savedGames.filter { $0.status != nil } }

    var body: some View {
        Group {
            if entries.isEmpty {
                VStack(spacing: 16) {
                    PageHeading(eyebrow: "YOUR STORY", title: "Play Journal", subtitle: "Remember the moments, achievements, and opinions that made each game yours.")
                    EmptyStateView(symbol: "book.closed", title: "Your journal starts here", message: availableGames.isEmpty ? "Add a game to your backlog before writing an entry." : "Write your first entry about a saved game.")
                }.padding(20)
            } else {
                List {
                    Section {
                        ForEach(entries) { entry in
                            Button { edit(entry) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(entry.gameName).font(.headline).foregroundStyle(.primary)
                                        Spacer()
                                        Text(entry.date, format: .dateTime.day().month(.abbreviated).year()).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Text(entry.text).lineLimit(3).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                                }.padding(.vertical, 6)
                            }.buttonStyle(.plain)
                        }.onDelete(perform: delete)
                    } header: {
                        Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                    }
                }.listStyle(.insetGrouped)
            }
        }
        .background(VaultTheme.background)
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { addEntry() } label: { Label("New entry", systemImage: "square.and.pencil") }
                    .disabled(availableGames.isEmpty)
            }
        }
        .sheet(item: $draft) { value in
            JournalEditorView(draft: value, games: availableGames) { save($0) }
        }
        .alert("Journal error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: { Text(errorMessage ?? "Please try again.") }
    }

    private func addEntry() {
        guard let game = availableGames.first else { return }
        draft = JournalDraft(entryID: nil, gameID: game.gameID, gameName: game.name, date: .now, text: "")
    }

    private func edit(_ entry: JournalEntry) {
        draft = JournalDraft(entryID: entry.id, gameID: entry.gameID, gameName: entry.gameName, date: entry.date, text: entry.text)
    }

    private func save(_ value: JournalDraft) {
        do {
            let trimmed = value.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            if let entryID = value.entryID, let entry = entries.first(where: { $0.id == entryID }) {
                entry.gameID = value.gameID
                entry.gameName = value.gameName
                entry.date = value.date
                entry.text = trimmed
            } else {
                context.insert(JournalEntry(gameID: value.gameID, gameName: value.gameName, date: value.date, text: trimmed))
            }
            try context.save()
            draft = nil
        } catch {
            context.rollback()
            errorMessage = "The journal entry couldn't be saved."
        }
    }

    private func delete(at offsets: IndexSet) {
        do {
            for index in offsets { context.delete(entries[index]) }
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "The journal entry couldn't be deleted."
        }
    }
}

private struct JournalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let games: [SavedGame]
    let onSave: (JournalDraft) -> Void
    @State private var value: JournalDraft

    init(draft: JournalDraft, games: [SavedGame], onSave: @escaping (JournalDraft) -> Void) {
        _value = State(initialValue: draft)
        self.games = games
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Game", selection: $value.gameID) {
                    ForEach(games) { game in Text(game.name).tag(game.gameID) }
                }.onChange(of: value.gameID) { _, id in
                    value.gameName = games.first(where: { $0.gameID == id })?.name ?? value.gameName
                }
                DatePicker("Played on", selection: $value.date, displayedComponents: .date)
                Section("Experience, achievement, or opinion") {
                    TextEditor(text: $value.text).frame(minHeight: 180)
                }
            }
            .navigationTitle(value.entryID == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(value) }
                        .disabled(value.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
