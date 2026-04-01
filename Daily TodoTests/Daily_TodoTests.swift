//
//  Daily_TodoTests.swift
//  Daily TodoTests
//
//  Created by MD Younus Foysal on 1/4/26.
//

import Foundation
import Testing
@testable import Daily_Todo

@MainActor
struct Daily_TodoTests {

    // MARK: - Add

    @Test func addTaskAppendsItem() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Write tests")
        #expect(store.items.count == 1)
        #expect(store.items.first?.title == "Write tests")
    }

    @Test func addTaskTrimsWhitespace() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "  Leading space  ")
        #expect(store.items.first?.title == "Leading space")
    }

    @Test func addEmptyTaskIsIgnored() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "   ")
        #expect(store.items.isEmpty)
    }

    // MARK: - Update

    @Test func updateTaskChangesTitle() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Old title")
        let id = store.items[0].id
        store.update(id: id, newTitle: "New title")
        #expect(store.items.first?.title == "New title")
    }

    @Test func updateWithEmptyTitleIsIgnored() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Keep me")
        let id = store.items[0].id
        store.update(id: id, newTitle: "  ")
        #expect(store.items.first?.title == "Keep me")
    }

    // MARK: - Delete

    @Test func deleteRemovesItem() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Task A")
        store.add(title: "Task B")
        let id = store.items[0].id
        store.delete(id: id)
        #expect(store.items.count == 1)
        #expect(store.items.first?.title == "Task B")
    }

    // MARK: - Clear All

    @Test func clearAllRemovesEverything() async throws {
        let store = TodoStore()
        store.add(title: "One")
        store.add(title: "Two")
        store.clearAll()
        #expect(store.items.isEmpty)
    }

    // MARK: - EOD Report

    @Test func copyToClipboardFormatsReport() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Task One")
        store.add(title: "Task Two")
        let report = store.copyToClipboard()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let today = formatter.string(from: Date())
        #expect(report.contains("**End of Day Report: \(today)**"))
        #expect(report.contains("1. Task One"))
        #expect(report.contains("2. Task Two"))
    }

    // MARK: - New Day

    @Test func newDayPromptNotShownWhenEmpty() async throws {
        let store = TodoStore()
        store.clearAll()
        store.checkForNewDay()
        #expect(store.showNewDayPrompt == false)
    }

    @Test func startFreshClearsItems() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Yesterday's task")
        store.startFreshToday()
        #expect(store.items.isEmpty)
        #expect(store.showNewDayPrompt == false)
    }

    @Test func keepYesterdayTasksPreservesItems() async throws {
        let store = TodoStore()
        store.clearAll()
        store.add(title: "Carry over")
        store.showNewDayPrompt = true
        store.keepYesterdayTasks()
        #expect(store.items.count == 1)
        #expect(store.showNewDayPrompt == false)
    }
}

