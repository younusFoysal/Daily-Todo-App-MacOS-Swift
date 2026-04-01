//
//  TodoStore.swift
//  Daily Todo
//
//  Created by MD Younus Foysal on 1/4/26.
//

import AppKit
import SwiftUI

// MARK: - Model

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    let createdAt: Date

    init(id: UUID = UUID(), title: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

// MARK: - Store

@MainActor
final class TodoStore: ObservableObject {
    @Published var items: [TodoItem] = []

    private let defaultsKey = "dailyTodo.items"

    init() {
        load()
    }

    // MARK: CRUD

    func add(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(TodoItem(title: trimmed))
        save()
    }

    func update(id: UUID, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].title = trimmed
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func clearAll() {
        items.removeAll()
        save()
    }

    // MARK: Copy EOD Report

    @discardableResult
    func copyToClipboard() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())

        var lines = ["**End of Day Report: \(dateString)**"]
        for (index, item) in items.enumerated() {
            lines.append("\(index + 1). \(item.title)")
        }

        let report = lines.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(report, forType: .string)
        return report
    }

    // MARK: Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
        items = decoded
    }
}
