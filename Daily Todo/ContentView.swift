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
                    Text("Daily Todo")
                        .font(.headline)
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !store.items.isEmpty {
                    Button(role: .destructive) {
                        store.clearAll()
                        editingID = nil
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
                        .foregroundStyle(newTaskText.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .accentColor)
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
                    ForEach(store.items) { item in
                        TaskRowView(
                            item: item,
                            editingID: $editingID,
                            editingText: $editingText,
                            onCommit: { commitEdit(id: item.id) },
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

            // ── Footer: Copy Button ──────────────────────────────────
            HStack {
                Spacer()
                Button {
                    _ = store.copyToClipboard()
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
                    .foregroundStyle(store.items.isEmpty ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(store.items.isEmpty)
                .padding(.trailing, 14)
            }
            .padding(.vertical, 10)
        }
        .frame(width: 320, height: 480)
        .onAppear { addFieldFocused = true }
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
}

// MARK: - Task Row

struct TaskRowView: View {
    let item: TodoItem
    @Binding var editingID: UUID?
    @Binding var editingText: String
    let onCommit: () -> Void
    let onDelete: () -> Void

    @FocusState private var rowFocused: Bool

    private var isEditing: Bool { editingID == item.id }

    var body: some View {
        HStack(spacing: 6) {
            // Row number
            Text("\u{2022}")
                .foregroundStyle(.secondary)
                .frame(width: 12)

            if isEditing {
                TextField("", text: $editingText)
                    .textFieldStyle(.plain)
                    .focused($rowFocused)
                    .onSubmit { onCommit() }
                    .onAppear { rowFocused = true }
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
            .opacity(isEditing ? 0 : 1)
        }
        .padding(.vertical, 3)
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
