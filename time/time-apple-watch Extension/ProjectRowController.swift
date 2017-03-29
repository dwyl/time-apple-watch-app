//
//  ProjectRowController.swift
//  time
//
//  Created by Sohil Pandya on 20/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ProjectRowController: NSObject {

    @IBOutlet var ProjectName: WKInterfaceLabel!
    @IBOutlet var startTimer: WKInterfaceImage!
    @IBOutlet var timer: WKInterfaceTimer!
    var isTimerRunning = false
    let startImage = UIImage(named: "fa-start")
    let stopImage = UIImage(named: "fa-stop")
    
    func startTimerForRow() {
        timer.setHidden(false)
        timer.setDate(Date(timeIntervalSinceNow: 0.0))
        timer.start()
        startTimer.setImage(stopImage)
    }
    
    func stopTimerForRow() {
        startTimer.setImage(startImage)
        timer.stop()
    }
}