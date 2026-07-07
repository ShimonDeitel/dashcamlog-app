import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ClipEntryStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: ClipEntry? = nil
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                ClipEntryTheme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .listRowBackground(ClipEntryTheme.card)
                        .accessibilityIdentifier("row_\(item.name)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Dash Cam Footage Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ClipEntryFormView(mode: .add) { new in
                    if !store.add(new) {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                ClipEntryFormView(mode: .edit(item)) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(id: item.id)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(ClipEntryTheme.accent)
    }

    @ViewBuilder
    private func row(for item: ClipEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(ClipEntryTheme.bodyFont)
                .foregroundColor(ClipEntryTheme.textPrimary)
            Text(item.detail)
                .font(ClipEntryTheme.captionFont)
                .foregroundColor(ClipEntryTheme.textSecondary)
            Text(item.date, style: .date)
                .font(ClipEntryTheme.captionFont)
                .foregroundColor(ClipEntryTheme.accent)
        }
        .padding(.vertical, 4)
    }
}

enum ClipEntryFormMode {
    case add
    case edit(ClipEntry)
}

struct ClipEntryFormView: View {
    let mode: ClipEntryFormMode
    var onSave: (ClipEntry) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Clip title") {
                    TextField("Clip title", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section("Incident type") {
                    TextField("Incident type", text: $detail)
                        .accessibilityIdentifier("detailField")
                }
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("noteField")
                }
                if case .edit = mode, let onDelete {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Clip" : "New Clip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear(perform: populate)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populate() {
        if case .edit(let item) = mode {
            name = item.name
            detail = item.detail
            date = item.date
            note = item.note
        }
    }

    private func save() {
        var item: ClipEntry
        if case .edit(let existing) = mode {
            item = existing
        } else {
            item = ClipEntry(name: name, detail: detail, date: date)
        }
        item.name = name
        item.detail = detail
        item.date = date
        item.note = note
        onSave(item)
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(ClipEntryStore())
        .environmentObject(PurchaseManager())
}
