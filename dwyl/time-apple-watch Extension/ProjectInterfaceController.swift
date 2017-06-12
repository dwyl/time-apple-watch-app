//
//  ProjectInterfaceController.swift
//  time
//
//  Created by Sohil Pandya on 18/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ProjectInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    
    
    // MARK: SETUP
    @IBOutlet var projectTable: WKInterfaceTable!
    var store = [String: Dictionary<String, Any> ]()
    var uniqueProjects = [String]()
    let applicationData = ["project": 0]
    
    
    //MARK: Timer Related Items
    var isTimerRunning = false
    var timerTotal = Timer()
    var totalTime = Double()
    var currentTimerForProjectName = ""
    
    //MARK: Watch Connection
    // set the wcsession as a method we can use in this file.
    fileprivate let session : WCSession? = WCSession.isSupported() ? WCSession.default() : nil

    // set it's delegate to the project interface controller and activate the session.
    override init() {
        super.init()
        session?.delegate = self
        session?.activate()
    }

    // This method runs once the session has been activated.
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //fetching data from watch
        fetchDataFromWatch(session: session)

    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if WCSession.isSupported() {
            let wcsession = WCSession.default()
            wcsession.delegate = self
            wcsession.activate()
        }
        fetchDataFromWatch(session: (session)!)
        
    }


    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        // ping the phone
        
        session?.sendMessage(["isTaskRunning": true], replyHandler: {
            replyData in
            
            if let project_name = replyData["project_name"] as? String {    
                if project_name != "noProject" {
                    
                    let start_date = replyData["start_date"] as! Date

                    // check if a task is running on the phone
                    // if it is then show it running on the watch....
                    self.currentTimerForProjectName = project_name
                    self.projectTable.setNumberOfRows(self.uniqueProjects.count, withRowType: "ProjectName")
                    self.isTimerRunning = true
                    self.timerTotal = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerOnWatch), userInfo: nil, repeats: true)
                    
                    for i in 0..<self.projectTable.numberOfRows {
                        
                        if let controller = self.projectTable.rowController(at: i) as? ProjectRowController {
                            controller.ProjectName.setText(self.uniqueProjects[i])
                            let red = self.store[self.uniqueProjects[i]]?["red"]
                            let green = self.store[self.uniqueProjects[i]]?["green"]
                            let blue = self.store[self.uniqueProjects[i]]?["blue"]
                            controller.projectGroup.setBackgroundColor(UIColor(red: red as! CGFloat, green: green as! CGFloat, blue: blue as! CGFloat, alpha: 1))
                            if (self.uniqueProjects[i] == project_name) {
                                controller.startTimerForRow(date: start_date)
                            }
                            
                        }
                    }
                }
            }
            print("You have sent the message!!! \(replyData)")
        }, errorHandler: { error in
            print("could not send name of the project for which the timer has started")
        })

        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // Loading the data into the tableview on the apple watch
    func reloadData () {
        
        // Setting the number of rows for the table
        projectTable.setNumberOfRows(uniqueProjects.count, withRowType: "ProjectName")

        // iterating through projects to show the information for each of them
        for i in 0..<uniqueProjects.count {
            if let controller = projectTable.rowController(at: i) as? ProjectRowController {
                controller.ProjectName.setText(uniqueProjects[i])
                let red = store[uniqueProjects[i]]?["red"]
                let green = store[uniqueProjects[i]]?["green"]
                let blue = store[uniqueProjects[i]]?["blue"]
                
                controller.projectGroup.setBackgroundColor(UIColor(red: red as! CGFloat, green: green as! CGFloat, blue: blue as! CGFloat, alpha: 1))
            }
        }
    }
    
    func fetchDataFromWatch (session: WCSession) {
        
        // Once the session is active, send a message to the iphone
        
        // check if timer is running 
        // send message to fetch data if it isn't running. 
        // update timer if its running on phone.
        // else update the store and reload data. 
        if !isTimerRunning {
            
        }
        
        
        
        session.sendMessage(applicationData,
                            replyHandler: { replyData in
                                // handle reply from iPhone app here
                                // we are setting the store and unique projects once we recive them from the iPhone
                                self.store = replyData["project"] as! [String : Dictionary<String, Any>]
                                self.uniqueProjects = replyData["uniqueProjects"] as! [String]
                                self.reloadData()
                                
        }, errorHandler: { error in
            // catch any errors here
            print(error)
        })
    }

    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            if (message["project"]) != nil {
                let receivedListOfUniqueProjects = message["uniqueProjects"] as! [String]
                
                if self.uniqueProjects == receivedListOfUniqueProjects {
                    // if the list of items being received are the same then we do not want to reload the data.
                    replyHandler(["set": true])
                } else {
                    self.store = message["project"] as! [String : Dictionary<String, Any>]
                    self.uniqueProjects = message["uniqueProjects"] as! [String]
                    self.reloadData()
                    replyHandler(["set": true])
                }
            }
            if (message["timerStoppedOnPhone"]) != nil {
                self.reloadData()
                self.timerTotal.invalidate()
            }
            if (message["timerStartedOnPhone"]) != nil {
                let project_name = message["project_name"] as! String
                let start_date = message["start_time"] as! Date
                // now that the timer has started on the phone
                // lets start it on the watch.
                // first step creat the watch singleton!!
                self.currentTimerForProjectName = project_name
                self.projectTable.setNumberOfRows(self.uniqueProjects.count, withRowType: "ProjectName")
                self.isTimerRunning = true
                self.timerTotal = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerOnWatch), userInfo: nil, repeats: true)

                for i in 0..<self.projectTable.numberOfRows {

                    if let controller = self.projectTable.rowController(at: i) as? ProjectRowController {
                        controller.ProjectName.setText(self.uniqueProjects[i])
                        let red = self.store[self.uniqueProjects[i]]?["red"]
                        let green = self.store[self.uniqueProjects[i]]?["green"]
                        let blue = self.store[self.uniqueProjects[i]]?["blue"]
                        controller.projectGroup.setBackgroundColor(UIColor(red: red as! CGFloat, green: green as! CGFloat, blue: blue as! CGFloat, alpha: 1))
                        if (self.uniqueProjects[i] == project_name) {
                            controller.startTimerForRow(date: start_date)
                        }
                 
                    }
                }
            }
        }
    }

    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        // if the user selects a given row what should happen next?
        if let cell = projectTable.rowController(at: rowIndex) as? ProjectRowController {
            


            //currently not much apart from changing the background color but this is where a lot of work will need to take place.
            // if timer is not running then start the timer
            if !isTimerRunning {
                cell.startTimerForRow(date: Date())
                startTimer(forProject: uniqueProjects[rowIndex])
            } else {
                
                // when the user selects the same cell we can
                    // stop the timer for the cell with the row index
                    // stop the timer UI
                    // set isTimerRunning to false
                if (currentTimerForProjectName == uniqueProjects[rowIndex]) {
                    cell.stopTimerForRow()
                    stopTimer(forProject: uniqueProjects[rowIndex], totalTime: totalTime)
                    currentTimerForProjectName = uniqueProjects[rowIndex]
                    isTimerRunning = false
                }
                // when the user selects a different cell
                // stop the timer for the currentTimerForProjectName send old timer infomation.
                // reload the data
                // send a message to the selected row to start the timer
                // set the currentTimerForProjectName to the selected Item
                // keep the isTimerRunning to true as we will start a new one
                // reset the timer to 0.0
                else {
                    stopTimer(forProject: currentTimerForProjectName, totalTime: totalTime)
                    // instead of reloading the data we can target the specific
                    let indexOf = uniqueProjects.index(of: currentTimerForProjectName)
                    if let cell = projectTable.rowController(at: indexOf!) as? ProjectRowController {
                        cell.ProjectName.setText(uniqueProjects[indexOf!])
                        cell.stopTimerForRow()
                    }
                    startTimer(forProject: uniqueProjects[rowIndex])
                    cell.startTimerForRow(date: Date())
                }
                
            }
            
          
            
        }
    }
    
    
    func startTimer(forProject project:String) {
        // when the timer is not running
        // start the timer
        currentTimerForProjectName = project
        // send a message to the phone which will save this data into the core data
        session?.sendMessage(["startTimerFor": project, "task_start_date": Date()], replyHandler: {
            replyData in
            print("You have sent the message!!! \(replyData)")
        }, errorHandler: { error in
            print("could not send name of the project for which the timer has started")
        })
        isTimerRunning = true
        timerTotal = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerOnWatch), userInfo: nil, repeats: true)
    }
    
    func stopTimer(forProject project:String, totalTime time:Double) {
        self.timerTotal.invalidate()
        // send a message to the phone which will update the existing project with the total time
        session?.sendMessage(["stopTimerFor": currentTimerForProjectName, "task_end_date": Date()], replyHandler: {
            replyData in
            // if the data is set then we can reset the totalTime to 0
                self.totalTime = 0.0
        }, errorHandler: { error in
            print("could not send name of the project for which the timer has started")
        })

    }
    
    func updateTimerOnWatch() {
        totalTime += 1.0

        if totalTime == 1500 {
            WKInterfaceDevice.current().play(.notification)
            let titleOfAlert = "Take a break?"
            let messageOfAlert = "it's been 25 mins"
            self.presentAlert(withTitle: titleOfAlert, message: messageOfAlert, preferredStyle: .alert, actions: [WKAlertAction(title: "OK", style: .default) {
                
                }]
            )
        }
        
    }

}
