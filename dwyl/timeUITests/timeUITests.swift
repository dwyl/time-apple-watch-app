//
//  timeUITests.swift
//  timeUITests
//
//  Created by Sohil Pandya on 06/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import XCTest
@testable import dwyl
import UIKit
import CoreData

class timeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
//        
//        let storeUrl = persistentContainer.persistentStoreCoordinator.persistentStores.first!.url!
//        let fileManager = FileManager.default
//        fileManager.removeItem(at: storeUrl)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }
    
    func testAddingNewProject() {
        
        let app = XCUIApplication()
        app.navigationBars["dwyl.TasksTableView"].buttons["Add"].tap()
        
        let newTaskTextField = app.textFields["New Task"]
        newTaskTextField.tap()
        newTaskTextField.typeText("Test")
        app.typeText("\r")
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 1, "found instead: \(cells.debugDescription)")
        
        let cellText = app.tables.cells.staticTexts["Test"].exists
        print("\(cellText)<<<<<<<<<<<<<<")
        XCTAssertEqual(cellText, true, "Test project exists")

    }
    
    func testViewingProject() {
        
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["Test"].tap()
        
        let titleExists = app.staticTexts["Test"].exists
        XCTAssertEqual(titleExists, true, "Project Title exists in the project detail view")

        let timerIsShownWithNoTimerRunning = app.staticTexts["00:00:00"].exists
        XCTAssertEqual(timerIsShownWithNoTimerRunning, true, "Project Title exists in the project detail view")

        
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 0, "New Project has no existing times")
        
        
        let backButtonExists = app.navigationBars["dwyl.ViewTaskView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).exists
        XCTAssertEqual(backButtonExists, true, "New Project has no existing times")

        let playButton = app.buttons["▶️"].exists
        XCTAssertEqual(playButton, true, "Play button exists")
        
        let stopButton = app.buttons["⏹"].exists
        XCTAssertEqual(stopButton, true, "Stop button exists")
        
    }
    
    func testRunTimerForProject() {
        
        
        let app = XCUIApplication()
        app.tables.staticTexts["Test"].tap()
        app.buttons["▶️"].tap()
        
        let isPlayButtonenabled = app.buttons["▶️"].isEnabled
        XCTAssertEqual(isPlayButtonenabled, false, "Play button is disabled, user cannot click it until the timer is stopped.")
        
        app.buttons["⏹"].tap()

        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 1, "New Task has been added to the table")
        
        let TaskTimerText = cells.staticTexts["00:00:00"].exists
        XCTAssertEqual(TaskTimerText, false, "This timer has run and is not equal to 0 seconds")
        let isPlayButtondisabled = app.buttons["▶️"].isEnabled
        XCTAssertEqual(isPlayButtondisabled, true, "Play button is enabled, user should be able to click it.")

    }
    
    func testTimerStillRunningWhenUserLeavesDetailedView() {
        
        let app = XCUIApplication()
        let backButton = app.navigationBars["dwyl.ViewTaskView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
        app.tables.staticTexts["Test"].tap()
        app.buttons["▶️"].tap()
        backButton.tap()
        
        let liveTimerValue = app.staticTexts.element(matching: .any, identifier: "totalTime").label
        XCTAssertNotEqual(liveTimerValue, "00:00:00", "Timer is running as the label is not set to default")
        

        // see the timer running
        // return to detailed view
        app.tables.staticTexts["Test"].tap()
        app.buttons["⏹"].tap()

        let cells = app.tables.cells
        XCTAssertNotEqual(cells.count, 1, "Number of cells is greater than 1")
        // interestingly the uitesting suite does not have a .visible method so we cannot check
        // if a label is visible or hidden https://stackoverflow.com/questions/32891466/uitesting-xcode-7-how-to-tell-if-xcuielement-is-visible
        // let liveTimerHittable = app.staticTexts["liveTimer"].isVisible
        // XCTAssertEqual(liveTimerHittable, true)
    }

    
    func testRunningTimerForAnotherProject() {
        let app = XCUIApplication()
        let backButton = app.navigationBars["dwyl.ViewTaskView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
        
        app.tables.staticTexts["Test"].tap()
        app.buttons["▶️"].tap()
        backButton.tap()
        app.navigationBars["dwyl.TasksTableView"].buttons["Add"].tap()
        let newTaskTextField = app.textFields["New Task"]
        newTaskTextField.tap()
        newTaskTextField.typeText("Testing")
        app.typeText("\r")

        app.tables.staticTexts["Testing"].tap()
        app.buttons["▶️"].tap()
        let appAlert = app.alerts["Time is already running"].exists
        XCTAssertEqual(appAlert, true, "app alert has popped up")
        
        app.alerts["Time is already running"].buttons["OK"].tap()
        backButton.tap()
        
        
        let firstChild = app.tables.children(matching:.any).element(boundBy: 1)
        if firstChild.exists {
            let liveTimerValue = firstChild.staticTexts.element(matching: .any, identifier: "totalTime").label
            XCTAssertNotEqual(liveTimerValue, "00:00:00")
        }
    }
    
    func testDeleteProject() {
        let app = XCUIApplication()
        let tablesQuery = app.tables.cells
        
        tablesQuery.element(boundBy: 0).swipeLeft()
        tablesQuery.element(boundBy: 0).buttons["Delete"].tap()
        XCTAssertEqual(tablesQuery.count, 1, "Testing Project row has been deleted")
    }
    
    func testStopTimerAfterReopeningApp() {
        let app = XCUIApplication()
        let backButton = app.navigationBars["dwyl.ViewTaskView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
        var initialTotalTime = String()
        var newTotalTime = String()
    
        initialTotalTime = app.staticTexts.element(matching: .any, identifier: "totalTime").label
        app.tables.staticTexts["Test"].tap()
        app.buttons["⏹"].tap()
        backButton.tap()
        newTotalTime = app.staticTexts.element(matching: .any, identifier: "totalTime").label
        XCTAssertNotEqual(initialTotalTime, newTotalTime, "Initial Total time \(initialTotalTime) is not equal to the new total time \(newTotalTime) as the time from the previous timer has been added on")
    }
    
}
