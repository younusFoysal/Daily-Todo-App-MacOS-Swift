# RemoteIntegrity Daily Todo

A lightweight macOS app for tracking your daily tasks and generating End-of-Day (EOD) reports — accessible from both the menu bar and as a full window.

---

## Features

- **Menu bar quick access** — click the checklist icon in the menu bar to open a popover and manage tasks instantly without switching apps
- **Full main window** — open a resizable window from the Dock, Launchpad, or via *Open Main Window* in the menu bar icon's right-click menu
- **Add & edit tasks** — type to add tasks; click any task to edit it inline; press Return to save or Escape to cancel
- **Drag to reorder** — drag tasks up and down to reprioritize
- **Delete tasks** — hover over a task and click the ✕ button, or right-click for a context menu
- **Clear all** — trash button in the header with a confirmation dialog to prevent accidents
- **EOD report copy** — copies all tasks to the clipboard formatted as a numbered list with the current date, ready to paste into Slack or email
  ```
  Daily EOD - 05-07-2026
  1. Reviewed pull requests
  2. Fixed login bug
  3. Updated documentation
  ```
- **New Day detection** — when you open the app on a new day, it prompts you to either start fresh or carry over yesterday's tasks
- **Persistent storage** — tasks are saved automatically to `UserDefaults` and survive app restarts
- **About & Quit** — right-click the menu bar icon for version info, About dialog, and Quit

---

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16 or later (for building from source)

---

## Build from Source

### 1. Clone / open the project

```bash
cd "/Volumes/Cloude/Xcode/Daily Todo"
open "Daily Todo/Daily Todo.xcodeproj"
```

### 2. Build a Release binary via Terminal

```bash
xcodebuild \
  -scheme "Daily Todo" \
  -configuration Release \
  -derivedDataPath /tmp/DailyTodoBuild \
  clean build
```

The built `.app` will be at:
```
/tmp/DailyTodoBuild/Build/Products/Release/Daily Todo.app
```

### 3. Patch the app icon into Info.plist (required when building with CLI)

```bash
APP="/tmp/DailyTodoBuild/Build/Products/Release/Daily Todo.app"
plutil -insert CFBundleIconFile -string AppIcon \
  "$APP/Contents/Info.plist" 2>/dev/null || \
  plutil -replace CFBundleIconFile -string AppIcon \
  "$APP/Contents/Info.plist"
codesign --force --deep --sign - "$APP"
```

---

## Create a DMG for Distribution

Run this after completing the build above:

```bash
APP="/tmp/DailyTodoBuild/Build/Products/Release/Daily Todo.app"
DMG="/Volumes/Cloude/Xcode/Daily Todo/Daily Todo.dmg"
STAGING="$(mktemp -d)/Daily Todo"

# Stage the app + Applications symlink so users can drag-and-drop to install
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

# Remove old DMG if it exists
rm -f "$DMG"

# Create the DMG from the staging folder
hdiutil create \
  -volname "Daily Todo" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$DMG"

# Clean up staging
rm -rf "$(dirname "$STAGING")"

echo "DMG created: $DMG"
```

The DMG will be created at:
```
/Volumes/Cloude/Xcode/Daily Todo/Daily Todo.dmg
```

---

## Install

1. Double-click `Daily Todo.dmg`
2. Drag `Daily Todo.app` to your **Applications** folder
3. Launch from Applications or Launchpad
4. On first launch, macOS may show a security prompt — go to **System Settings → Privacy & Security** and click **Open Anyway**

## Uninstall

1. Right-click the menu bar icon → **Quit Daily Todo** (or open the main window → ⌘Q)
2. Delete `Daily Todo.app` from your Applications folder
3. Optionally remove saved tasks: `defaults delete RemoteIntegrity.Daily-Todo`

---

## Usage

| Action | How |
|---|---|
| Open quick popover | Click the checklist icon in the menu bar |
| Open main window | Right-click menu bar icon → *Open Main Window*, or relaunch from Applications/Dock |
| Add a task | Type in the "Add a task…" field and press Return |
| Edit a task | Click on any task text |
| Delete a task | Hover over a task → click ✕, or right-click → Delete |
| Reorder tasks | Drag and drop |
| Copy EOD report | Click **Copy EOD Report** button (or press ⌘⇧C) |
| Clear all tasks | Click the trash icon in the header and confirm |
| Quit the app | Right-click menu bar icon → *Quit Daily Todo* |

---

## License

© 2026 RemoteIntegrity LLC. All rights reserved.
