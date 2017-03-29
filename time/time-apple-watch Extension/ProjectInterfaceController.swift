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

    @IBOutlet var projectTable: WKInterfaceTable!
    var store = [String: Dictionary<String, Any> ]()
    var uniqueProjects = [String]()
    let applicationData = ["project": 0]
    
    
    //MARK: Timer Related Items
    var isTimerRunning = false
    let startImage = UIImage(named: "fa-start")
    let stopImage = UIImage(named: "fa-stop")
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
    
    // Loading the data into the tableview on the apple watch
    func reloadData () {
        
        // Setting the number of rows for the table
        projectTable.setNumberOfRows(uniqueProjects.count, withRowType: "ProjectName")
        
        // iterating through projects to show the information for each of them
        for i in 0..<projectTable.numberOfRows {
            if let controller = projectTable.rowController(at: i) as? ProjectRowController {
                controller.ProjectName.setText(uniqueProjects[i])
            }
        }
    }
    

    func send(fromProject:String){
        
    }
    
    func fetchDataFromWatch (session: WCSession) {
        
        // Once the session is active, send a message to the iphone
        session.sendMessage(applicationData,
                            replyHandler: { replyData in
                                // handle reply from iPhone app here
                                // we are setting the store and unique projects once we recive them from the iPhone
                                self.store = replyData["project"] as! [String : Dictionary<String, Any>]
                                self.uniqueProjects = replyData["uniqueProjects"] as! [String]
                                print("store \(self.uniqueProjects)>>>>>>>>>>>>")
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
                
                print("Instant Message")
                if self.uniqueProjects == receivedListOfUniqueProjects {
                    // if the list of items being received are the same then we do not want to reload the data.
                    replyHandler(["set": true])
                } else {
                    self.store = message["project"] as! [String : Dictionary<String, Any>]
                    self.uniqueProjects = message["uniqueProjects"] as! [String]
                    print("store \(self.uniqueProjects)>>>>>>>>>>>>")
                    self.reloadData()
                    replyHandler(["set": true])
                }
            }
            
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("YOU HAVE STARTED THE WATCH AGAIN!")
        fetchDataFromWatch(session: (session)!)

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        // if the user selects a given row what should happen next?
        if let cell = projectTable.rowController(at: rowIndex) as? ProjectRowController {
            //currently not much apart from changing the background color but this is where a lot of work will need to take place.

            // if timer is not running then start the timer
            
            if !isTimerRunning {
                cell.startTimerForRow()
                startTimer(forProject: uniqueProjects[rowIndex])
            } else {
                cell.stopTimerForRow()
                stopTimer(forProject: uniqueProjects[rowIndex], totalTime: totalTime)
            }
            
        }
    }
    
    
    func startTimer(forProject project:String) {
        // when the timer is not running
        // start the timer
        currentTimerForProjectName = project
        print("YOU ARE IN START TIMER \(project) <<PROJECT and \(currentTimerForProjectName) CURRENT TIMER FOR PROJECT NAME<<<<<")
        // send a message to the phone which will save this data into the core data
        session?.sendMessage(["startTimerFor": project], replyHandler: {
            replyData in
            print("You have sent the message!!! \(replyData)")
        }, errorHandler: { error in
            print("could not send name of the project for which the timer has started")
        })
        isTimerRunning = true
        timerTotal = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerOnWatch), userInfo: nil, repeats: true)
    }
    
    func stopTimer(forProject project:String, totalTime time:Double) {
        print("Stopped the timer at \(totalTime)")

        
        // send a message to the phone which will update the existing project with the total time
        session?.sendMessage(["stopTimerFor": currentTimerForProjectName, "total_task_time": totalTime], replyHandler: {
            replyData in
            
            // if the data is set then we can reset the totalTime to 0
            print("You have sent the message!!! \(String(describing: replyData["savedToCoreData"]))")
            if (replyData["savedToCoreData"] != nil) {
                self.isTimerRunning = false
                self.timerTotal.invalidate()
                self.totalTime = 0.0
            }
            
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

        // if time reaches 25 mins, we can send a notification to the watch saying please take a break???
        // option 1 to take a break
        // option 2 to continue...
        
        
    }

}
