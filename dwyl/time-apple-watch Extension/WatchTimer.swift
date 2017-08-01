//
//  WatchTimer.swift
//  dwyl
//
//  Created by Sohil Pandya on 17/07/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit

class WatchTimer {
    
    static let sharedInstance = WatchTimer()
    private init() {
        print("you are in watch timer")
    }
    
    var startDate: Date? = nil
    var projectName: String? = nil
    var isTimerRunning: Bool = false
}
 
