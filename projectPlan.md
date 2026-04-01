# Daily Todo – Project Plan

A lightweight macOS menu bar app to track and export daily tasks as an EOD report.

---

## Target Output Format

When the copy button is pressed, the clipboard will contain:

```
**End of Day Report: 01-04-2026**
1. Meeting with Morshed - Fruum Testing and Bugs listing
2. Research on Redis configuration
3. Research on Tracker software optimization
```

---

## Steps

### Step 1 – Configure the Xcode Project for a Menu Bar App
- Remove the default window-based app lifecycle.
- Set `LSUIElement = YES` in `Info.plist` so the app has no Dock icon and no main window.
- Change the app entry point (`Daily_TodoApp.swift`) to use `NSApplicationDelegate` / `AppDelegate` instead of the SwiftUI `@main` `App` struct, so we can control `NSStatusBar`.

### Step 2 – Create the AppDelegate
- Create `AppDelegate.swift`.
- Add an `NSStatusItem` with a fixed-length button (use SF Symbol `checklist` or `list.bullet`).
- Wire the status item button action to show/hide the popover.
- Create and hold an `NSPopover` instance; set its content to the main SwiftUI view.

### Step 3 – Create the Data Model
- Create `TodoStore.swift` — an `ObservableObject` class.
- Define a `TodoItem` struct with `id: UUID`, `title: String`, and `createdAt: Date`.
- Store items in a `@Published var items: [TodoItem]` array.
- Persist items using `UserDefaults` (encode/decode with `JSONEncoder`).
- Add methods: `add(title:)`, `update(id:newTitle:)`, `delete(id:)`, `reorder(from:to:)`.

### Step 4 – Build the Main Popover View (`ContentView`)
- Replace the current placeholder `ContentView.swift` with the real UI.
- Layout (top→bottom):
  1. **Header** – app title "Daily Todo" + today's date.
  2. **Add Task field** – `TextField` with placeholder "Add a task…" + submit on Return key.
  3. **Task List** – `List` of `TodoItem`s; tapping a row switches it to an inline edit field.
  4. **Footer** – "Copy EOD Report" button aligned to the trailing edge.
- Inject `TodoStore` as an `@EnvironmentObject`.

### Step 5 – Implement Inline Task Editing
- Each row shows the task title as `Text` by default.
- Tapping a row sets `editingID` state to that item's id, replacing `Text` with a focused `TextField`.
- Pressing Return or clicking outside commits the edit (calls `store.update(id:newTitle:)`).
- Add a swipe-to-delete or a delete button (trash icon) per row.

### Step 6 – Implement the Copy EOD Report Function
- In `TodoStore`, add a `copyToClipboard()` method.
- Format today's date as `dd-MM-yyyy`.
- Build the string:
  ```
  **End of Day Report: <date>**
  1. First task
  2. Second task
  ```
- Write the string to `NSPasteboard.general`.
- Show brief visual feedback in the UI (e.g., button label changes to "Copied ✓" for 1.5 s).

### Step 7 – Polish & UX Details
- Auto-focus the "Add Task" text field when the popover opens.
- Show an empty-state message ("No tasks yet. Add one above ↑") when the list is empty.
- Set a fixed popover size (e.g., 320 × 480 pt) so it never resizes awkwardly.
- Support drag-to-reorder rows in the list.
- Add a "Clear All" option (with confirmation) accessible via a context menu or toolbar button.

### Step 8 – Auto-Reset for a New Day (Optional)
- On app launch / popover open, check if the last saved date differs from today.
- If a new day is detected, optionally prompt the user: "Start fresh for today?" (keep or clear yesterday's tasks).

### Step 9 – App Icon & Assets
- Replace the placeholder `AppIcon` in `Assets.xcassets` with a proper icon (checklist style).
- Ensure the status bar icon is a template image (black & white, 18×18 pt `@2x`) so it adapts to light/dark menu bar.

### Step 10 – Build, Test & Archive
- Run on macOS target; verify popover appears on menu bar icon click.
- Test add / edit / delete / reorder / copy workflows end-to-end.
- Confirm `UserDefaults` persistence survives app restarts.
- Archive and export as a `.app` bundle if needed for distribution.

---

## File Structure (after all steps)

```
Daily Todo/
├── AppDelegate.swift          # NSStatusItem + NSPopover setup
├── ContentView.swift          # Main popover SwiftUI view
├── TodoStore.swift            # ObservableObject data model + persistence
├── Daily_TodoApp.swift        # @main entry point wiring AppDelegate
└── Assets.xcassets/
    └── AppIcon.appiconset/    # Menu bar template icon + app icon
```

---

## Notes
- Minimum deployment target: **macOS 13 Ventura** (uses modern SwiftUI APIs).
- No third-party dependencies required — pure SwiftUI + AppKit.
- All data is stored locally in `UserDefaults`; no network access needed.
