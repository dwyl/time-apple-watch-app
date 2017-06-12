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
    
    
    

    @IBOutlet var timerGroup: WKInterfaceGroup!
    @IBOutlet var ProjectName: WKInterfaceLabel!
    @IBOutlet var startTimer: WKInterfaceImage!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var projectGroup: WKInterfaceGroup!
    var isTimerRunning = false
    let startImage = UIImage(named: "fa-start")
    let stopImage = UIImage(named: "fa-stop")
    
    
    func startTimerForRow(date: Date) {
        timerGroup.setHidden(false)
        timer.setHidden(false)
        timer.setDate(date)
        timer.start()
        startTimer.setImage(stopImage)
    }
    
    func stopTimerForRow() {
        startTimer.setImage(startImage)
        timer.stop()
    }
}
