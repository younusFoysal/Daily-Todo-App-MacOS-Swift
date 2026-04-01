//
//  Daily_TodoUITests.swift
//  Daily TodoUITests
//
//  Created by MD Younus Foysal on 1/4/26.
//

import XCTest

final class Daily_TodoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppLaunchesWithoutMainWindow() throws {
        // Daily Todo is a menu bar app — it must NOT open a main window on launch.
        let app = XCUIApplication()
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 5)
        XCTAssertEqual(app.windows.count, 0,
                       "Menu bar app should have no main window after launch.")
    }
}
