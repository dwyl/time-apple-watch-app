//
//  ProjectTimer.swift
//  dwyl time
//
//  Created by Sohil Pandya on 11/05/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import CoreData

class ProjectTimer {
    
    static let sharedInstance = ProjectTimer()
    private init() {
    print("you are in projectTimer")
    }

    var startDate = Date()
    var timeInSeconds = 0.0
    var timer = Timer()
    var timerRunning = false
    var projectName = String()
    
    func loadState() {
        print("Loading STATE")
        let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
        fetchRequest.predicate = NSPredicate(format: "is_task_running == YES")
        // fetch where task is running.
        do {
            let RunningProject = try managedObjectContext!.fetch(fetchRequest)
            if RunningProject.count == 1 {
                startTimer(name: (RunningProject.first?.project_name)!)
                projectName = (RunningProject.first?.project_name)!
                startDate = (RunningProject.first?.task_start_date as Date?)!
                updateTimer()
            }
        } catch let error as NSError {
            print("unable to get projects from core data. \(error)")
        }
    }
    
    func startTimer(name: String) {
        timerRunning = true
        startDate = Date()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // create a json object. 
        do {
            //     let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            let convertedDate = dateToString(date: startDate)
            let jsonData = try JSONSerialization.data(withJSONObject: ["project_name": name, "start_date": convertedDate, "isTaskRunning": true], options: .prettyPrinted)
            let jsonToString = String(data: jsonData, encoding: String.Encoding.utf8) // the data will be converted to the string

            print(jsonToString ?? "no data")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    

    
    func stopTimer() {
        startDate = Date()
        timer.invalidate()
        timerRunning = false
        timeInSeconds = 0
        projectName = String()
    }

    func isTimerRunning() -> Bool {
        return timerRunning
    }
    
    @objc func updateTimer() {
        
        timeInSeconds = Date().timeIntervalSince(startDate)
        //sendNotification to views that require this timer.
        let notification = NotificationCenter.default
        notification.post(name: Notification.Name(rawValue: "TimerUpdated" ), object: nil, userInfo: ["timeInSeconds" : Int(timeInSeconds)])
    }
}
