//
//  Daily_TodoApp.swift
//  Daily Todo
//
//  Created by MD Younus Foysal on 1/4/26.
//

import SwiftUI

@main
struct Daily_TodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows — the app lives entirely in the menu bar via AppDelegate.
        Settings { EmptyView() }
    }
}
