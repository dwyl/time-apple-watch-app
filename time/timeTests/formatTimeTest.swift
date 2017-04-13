//
//  formatTimeTest.swift
//  time
//
//  Created by Sohil Pandya on 11/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import XCTest
@testable import time

class formatTimeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTimeToTextGreaterThanTen() {
        let result = timeToText(s: 15)
        let expected = "15"
        XCTAssertEqual(result, expected)
    }
    
    func testTimeToTextGreaterLessThanTen() {
        let result = timeToText(s: 5)
        let expected = "05"
        XCTAssertEqual(result, expected)
    }
    
    func testFormatTime() {
        
        //give 1500 seconds should return 25 minutes
        let total_time = 1500
        let expected = "00h25m00s"
        
        secondsToHsMsSs(seconds: Int(total_time), result: {(hours, minutes, seconds) in
            let result = "\(timeToText(s: hours))h\(timeToText(s: minutes))m\(timeToText(s: seconds))s"
            XCTAssertEqual(expected, result)

        })
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    
    
}
