//
//  ProjectTimerTest.swift
//  dwyl
//
//  Created by Sohil Pandya on 13/06/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import XCTest
@testable import dwyl
import CoreData

class ProjectTimerTest: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        
        // I'm stopping the timer instance after every test.
        ProjectTimer.sharedInstance.stopTimer()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProjectTimerIsNotRunningByDefault() {
        let expected = ProjectTimer.sharedInstance.isTimerRunning()
        let actual = false
        XCTAssertEqual(expected, actual, "The timer is not reunning by default")
    }
    
    func testProjectTimerIsRunning() {
        
        ProjectTimer.sharedInstance.startTimer()
        let expected = ProjectTimer.sharedInstance.isTimerRunning()
        let actual = true
        XCTAssertEqual(expected, actual, "The timer has started and is running OK")
    
    }
    
    func testLoadStateWhenNoTaskRunningInBackground() {
        ProjectTimer.sharedInstance.loadState()
        let expected = ProjectTimer.sharedInstance.isTimerRunning()
        let actual = false
        XCTAssertEqual(expected, actual, "loadState returned no new data and timer has not been started")
        
    }
    
    
    
    func testPerformanceStartingTimer() {
        // This is an example of a performance test case.
        self.measure {
            // time taken to start the timer
            ProjectTimer.sharedInstance.startTimer()
        }
    }
    
}
