//
//  AppDelegate.swift
//  Daily Todo
//
//  Created by MD Younus Foysal on 1/4/26.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let store = TodoStore()
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start as accessory (no Dock icon) — main window switches to .regular when open.
        NSApp.setActivationPolicy(.accessory)

        // Use the asset-catalog AppIcon; fall back to the code-drawn one if not embedded yet.
        if let assetIcon = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = assetIcon
        } else {
            NSApp.applicationIconImage = .appIcon()
        }

        // 1. Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let icon = NSImage.menuBarTemplateIcon(size: 18)
            button.image = icon.size.width > 0 ? icon :
                NSImage(systemSymbolName: "checklist", accessibilityDescription: "Daily Todo")
            button.image?.isTemplate = true

            // Left-click → popover; right-click / ctrl-click → context menu
            button.action = #selector(handleStatusBarClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 2. Create the popover, injecting the shared TodoStore
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(store)
        )
    }

    // MARK: - Dock click / app reopen

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openMainWindow()
        }
        return true
    }

    // MARK: - Main Window

    func openMainWindow() {
        if let existing = mainWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "RemoteIntegrity Daily Todo"
        window.minSize = NSSize(width: 360, height: 400)
        window.center()
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(store)
                .frame(minWidth: 360, minHeight: 400)
        )

        // Track close to revert to accessory policy
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mainWindowWillClose),
            name: NSWindow.willCloseNotification,
            object: window
        )

        mainWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func mainWindowWillClose(_ notification: Notification) {
        // Return to accessory mode so the Dock icon disappears again
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    // MARK: - Status Bar Interaction

    @objc private func handleStatusBarClick() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Allow the popover to appear over full-screen apps and in all Spaces
            if let popoverWindow = popover.contentViewController?.view.window {
                popoverWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                popoverWindow.makeKey()
            }
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        // App name + version (non-clickable header)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build   = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        let appInfo = NSMenuItem(title: "Daily Todo  v\(version) (\(build))", action: nil, keyEquivalent: "")
        appInfo.isEnabled = false
        menu.addItem(appInfo)

        menu.addItem(.separator())

        // Open main window
        let openWindow = NSMenuItem(title: "Open Main Window", action: #selector(openMainWindowFromMenu), keyEquivalent: "")
        openWindow.target = self
        menu.addItem(openWindow)

        menu.addItem(.separator())

        // About
        let about = NSMenuItem(title: "About Daily Todo", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        menu.addItem(.separator())

        // Quit
        let quit = NSMenuItem(title: "Quit Daily Todo", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        // Show menu under the status bar button
        if let button = statusItem.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.maxY + 4), in: button)
        }
    }

    @objc private func openMainWindowFromMenu() {
        if popover.isShown { popover.performClose(nil) }
        openMainWindow()
    }

    @objc private func showAbout() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build   = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"

        let alert = NSAlert()
        alert.messageText = "RemoteIntegrity Daily Todo"
        alert.informativeText = """
            Version \(version) (Build \(build))

            A lightweight menu bar app for tracking your daily tasks and generating End-of-Day reports.

            © 2026 RemoteIntegrity LLC.
            """
        alert.alertStyle = .informational
        if let icon = NSImage(named: "AppIcon") {
            alert.icon = icon
        }
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}


