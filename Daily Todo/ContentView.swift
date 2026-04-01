//
//  ContentView.swift
//  Daily Todo
//
//  Created by MD Younus Foysal on 1/4/26.
//

import SwiftUI

// MARK: - Main Popover View

struct ContentView: View {
    @EnvironmentObject var store: TodoStore

    @State private var newTaskText = ""
    @State private var editingID: UUID? = nil
    @State private var editingText = ""
    @State private var copied = false
    @State private var showClearConfirm = false
    @FocusState private var addFieldFocused: Bool

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RemoteIntegrity Daily Todo")
                        .font(.headline)
                    HStack(spacing: 6) {
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !store.items.isEmpty {
                            Text("·")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Text("\(store.items.count) task\(store.items.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                Spacer()
                if !store.items.isEmpty {
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Clear all tasks")
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            // ── Add Task Field ───────────────────────────────────────
            HStack(spacing: 8) {
                TextField("Add a task…", text: $newTaskText)
                    .textFieldStyle(.plain)
                    .focused($addFieldFocused)
                    .onSubmit { submitNewTask() }

                Button(action: submitNewTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.accentColor))
                }
                .buttonStyle(.plain)
                .disabled(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()

            // ── Task List ────────────────────────────────────────────
            if store.items.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No tasks yet. Add one above ↑")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(Array(store.items.enumerated()), id: \.element.id) { index, item in
                        TaskRowView(
                            item: item,
                            index: index,
                            editingID: $editingID,
                            editingText: $editingText,
                            onCommit: { commitEdit(id: item.id) },
                            onCancel: { cancelEdit() },
                            onDelete: { store.delete(id: item.id) }
                        )
                        .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    }
                    .onMove { store.move(from: $0, to: $1) }
                    .onDelete { offsets in
                        offsets.forEach { store.delete(id: store.items[$0].id) }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: .infinity)
            }

            Divider()

            // ── Footer: Copy Button + Version ───────────────────────
            HStack {
                // Version info (left side)
                Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 14)

                Spacer()

                Button {
                    store.copyToClipboard()
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copied = false }
                    }
                } label: {
                    Label(
                        copied ? "Copied ✓" : "Copy EOD Report",
                        systemImage: copied ? "checkmark" : "doc.on.clipboard"
                    )
                    .font(.callout)
                    .foregroundStyle(store.items.isEmpty ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.accentColor))
                }
                .buttonStyle(.plain)
                .disabled(store.items.isEmpty)
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .padding(.trailing, 14)
            }
            .padding(.vertical, 10)
        }
        .onAppear {
            addFieldFocused = true
            store.checkForNewDay()
        }
        .alert("Clear All Tasks?", isPresented: $showClearConfirm) {
            Button("Clear All", role: .destructive) {
                store.clearAll()
                editingID = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all \(store.items.count) task\(store.items.count == 1 ? "" : "s").")
        }
        .alert("New Day ☀️", isPresented: $store.showNewDayPrompt) {
            Button("Start Fresh", role: .destructive) {
                store.startFreshToday()
                editingID = nil
            }
            Button("Keep Tasks") {
                store.keepYesterdayTasks()
            }
        } message: {
            Text("You have \(store.items.count) unfinished task\(store.items.count == 1 ? "" : "s") from yesterday. Start fresh or keep them?")
        }
    }

    private func submitNewTask() {
        store.add(title: newTaskText)
        newTaskText = ""
        addFieldFocused = true
    }

    private func commitEdit(id: UUID) {
        store.update(id: id, newTitle: editingText)
        editingID = nil
        editingText = ""
    }

    private func cancelEdit() {
        editingID = nil
        editingText = ""
    }
}

// MARK: - Task Row

struct TaskRowView: View {
    let item: TodoItem
    let index: Int
    @Binding var editingID: UUID?
    @Binding var editingText: String
    let onCommit: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void

    @FocusState private var rowFocused: Bool
    @State private var isHovered = false

    private var isEditing: Bool { editingID == item.id }

    var body: some View {
        HStack(spacing: 6) {
            // Row number (matches EOD report numbering)
            Text("\(index + 1).")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            if isEditing {
                TextField("", text: $editingText)
                    .textFieldStyle(.plain)
                    .focused($rowFocused)
                    .onSubmit { onCommit() }
                    .onExitCommand { onCancel() }   // Escape cancels
                    .onAppear { rowFocused = true }
                    // Commit when the field loses focus (user clicked elsewhere)
                    .onChange(of: rowFocused) { _, focused in
                        if !focused { onCommit() }
                    }
            } else {
                Text(item.title)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingID = item.id
                        editingText = item.title
                    }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(isHovered && !isEditing ? 1 : 0)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovered && !isEditing ? Color.primary.opacity(0.06) : .clear)
        )
        .onHover { isHovered = $0 }
        .contextMenu {
            Button("Edit") {
                editingID = item.id
                editingText = item.title
            }
            Divider()
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
}

#Preview {
    let store = TodoStore()
    store.add(title: "Meeting with Morshed - Fruum Testing")
    store.add(title: "Research on Redis configuration")
    store.add(title: "Research on Tracker software optimization")
    return ContentView()
        .environmentObject(store)
}
