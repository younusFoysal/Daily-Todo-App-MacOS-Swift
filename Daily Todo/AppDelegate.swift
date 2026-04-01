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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Daily Todo")
            button.image?.isTemplate = true   // adapts to light / dark menu bar
            button.action = #selector(togglePopover)
            button.target = self
        }

        // 2. Create the popover, injecting the shared TodoStore
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient            // closes when user clicks away
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(store)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
