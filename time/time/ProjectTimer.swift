//
//  ProjectTimer.swift
//  dwyl time
//
//  Created by Sohil Pandya on 11/05/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation

class ProjectTimer {
    
    static let sharedInstance = ProjectTimer()
    private init() { }

    var timeInSeconds = 0
    var timer = Timer()
    var timerRunning = false
    var projectName = String()
    
    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
        timerRunning = false
        timeInSeconds = 0
        projectName = String()
    }

    func isTimerRunning() -> Bool {
        return timerRunning
    }
    
    @objc func updateTimer() {
        timeInSeconds += 1
        //sendNotification to views that require this timer.
        let notification = NotificationCenter.default
        notification.post(name: Notification.Name(rawValue: "TimerUpdated" ), object: nil, userInfo: ["timeInSeconds" : timeInSeconds])
    }
}
