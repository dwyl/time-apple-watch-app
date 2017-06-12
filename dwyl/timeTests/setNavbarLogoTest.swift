//
//  setNavbarLogoTest.swift
//  time
//
//  Created by Sohil Pandya on 11/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import XCTest
@testable import time

class setNavbarLogoTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetNavbarLogo() {
        
        //idea is to test if it retuns a UIView?
        let result = setNavbarLogo()        
        // I am not sure the best way to do a deep eqaul. So just checking if it is not nil for now.
        XCTAssertNotNil(result)
    }
    
}
