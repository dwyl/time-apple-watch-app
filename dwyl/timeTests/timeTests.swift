//
//  timeTests.swift
//  timeTests
//
//  Created by Sohil Pandya on 06/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import XCTest
@testable import dwyl


class timeTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let navigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
        let tableViewController = navigationController.viewControllers[0] as! TasksTableViewController
        
    }
    
    
}
