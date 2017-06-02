//
//  TasksTableViewController.swift
//  time
//
//  Created by Sohil Pandya on 06/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import WatchConnectivity


class TasksTableViewController: UITableViewController, WCSessionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()

        let navView = setNavbarLogo()
        self.navigationItem.titleView = navView
        
        configureWCSession() // activate the WCSession
        projects = fetchProjectNames(managedObjectContext: managedObjectContext!) // fetch the list of project names
        // SETTING UP THE STORE
        setupStore()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DEINIT")
    }
    
    
    // MARK: NOTIFICATIONS
    
    func subscribeToNotifications() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector:#selector(self.handleUpdateTimer), name: Notification.Name(rawValue: "TimerUpdated"), object: nil)
        notification.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        notification.addObserver(self, selector: #selector(timerStoppedOnPhone), name: NSNotification.Name(rawValue: "timerStoppedOnPhone"), object: nil)
    }
    
    func handleUpdateTimer(notification:Notification) -> Void {
        
        if let userInfo = notification.userInfo, let timeInSeconds = userInfo["timeInSeconds"] as? Int {
            // user has started timer in watch
            // we can start a timer here and send the data to the particular tableviewcell
            let projectName = ProjectTimer.sharedInstance.projectName

            if let rowForCell = self.uniqueProjects.index(of: projectName) {
                let indexPath = IndexPath(row: rowForCell, section: 0)
                let tableRow = self.tableView.cellForRow(at: indexPath) as! TasksTableViewCell
                tableRow.liveTimer.isHidden = false
                secondsToHsMsSs(seconds: timeInSeconds) { (hours, minutes, seconds) in
                    tableRow.liveTimer.text = "\(timeToText(s: hours)):\(timeToText(s: minutes)):\(timeToText(s: seconds))"
                }
            }
        }
    }
    


    // MARK: SETUP
    // Here you'll find all the initialising for this particular view controller (Home Page Table View)
    
    // Create a session so that we can interact with the Apple Watch at a later time using it.
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    // setup the managed context required for connecting with the core data
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    var projects: [Project] = [] // List of projects as an array. These are of the class Project from Code Data
    var projectNames = [String]() // List of project names.
    var uniqueProjects = [String]() // List of unique project names
    var store = [String: Dictionary<String, Any>]() // Data structure that contains information about each individual project as shown in the example below
    /*
     This is how the localStore will look like.
     var store =
     {
        "ios" : {
            "project_name": "iOS",
            "total_time":0
            "color":"blue"
        },
        "elm": {
            "project_name": "elm",
            "total_time":0
            "color":"blue"
        }
     }
     */
    
    
    
    //WATCH
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureWCSession()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureWCSession()
    }
    
    fileprivate func configureWCSession() {
        session?.delegate = self;
        session?.activate()
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            if (message["project"] as? Int) != nil {
                replyHandler(["project": self.store , "uniqueProjects": self.uniqueProjects])
            }
            if (message["startTimerFor"] as? String) != nil {
                
                if ProjectTimer.sharedInstance.isTimerRunning() {
                    print("cant start timer, another one is already running in \(ProjectTimer.sharedInstance.projectName)")
                } else {
                    ProjectTimer.sharedInstance.startTimer()
                    ProjectTimer.sharedInstance.projectName = message["startTimerFor"] as! String
                }
                

                // save the given item to the coredata create a new field called fromAppleWatch which we have to set to true here.
                
                if let newTaskInProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: self.managedObjectContext!)  as? Project {
                    // setting from apple watch to true as this comes from the apple watch
                    newTaskInProject.task_start_date = message["task_start_date"] as? NSDate
                    newTaskInProject.from_apple_watch = true
                    newTaskInProject.project_name = message["startTimerFor"] as! String?
                    newTaskInProject.is_task_running = true
                    
                }
                // 4
                do {
                    try self.managedObjectContext!.save()
                    replyHandler(["savedToCoreData": true])
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
            if (message["stopTimerFor"] as? String) != nil {
                
                if ProjectTimer.sharedInstance.isTimerRunning() {
                    //stop the timer
                    ProjectTimer.sharedInstance.stopTimer()
                } else {
                    print("you need to start a timer before stopping it!")
                }
                
                
                let project_name = message["stopTimerFor"] as! String?
                let fetchRequest =  NSFetchRequest<Project>(entityName: "Project")
                //        let predicate = NSPredicate(format: "any project_name = %@", name)
                let predicate1 = NSPredicate(format: "project_name == %@", project_name!)
                let predicate2 = NSPredicate(format: "is_task_running == YES")
                let predicate3 = NSPredicate(format: "from_apple_watch == YES")
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3])
                
                do {
                    fetchRequest.predicate = predicateCompound
                    
                    let project = try self.managedObjectContext!.fetch(fetchRequest)
                    // now set the task end date, is task running and total task time and then save the project
                    
                    let task_start_date = project.first?.task_start_date
                    let task_end_date = message["task_end_date"] as? NSDate
                    
                    // time is now calculated using the difference in two dates.
                    let total_task_time = task_end_date?.timeIntervalSince((task_start_date! as Date))
                    project.first?.task_end_date = message["task_end_date"] as? NSDate
                    project.first?.is_task_running = false
                    project.first?.total_task_time = Double(total_task_time!)
                    
                    
                    do {
                        self.loadList()
                        replyHandler(["savedToCoreData": "YOU SAVED TO THE DB"])
                        try self.managedObjectContext!.save()
                        self.tableView.reloadData()
                        
                    } catch let error as NSError {
                        print("unable to save project. \(error)")
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                // update and save the given item to the coredata
                
            }
            
        }
    }

    
    //PHONE
    
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        //maybe we want to do something when the session between the two devices deactivates
        // it can be done here
    
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    
    
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {

    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }
    
    func setupStore() {

        // SETTING UP THE STORE
        
        // find unique projects
        var aggregatedProjects = [String]()
        for p in projects {
            aggregatedProjects.append(p.project_name!)
        }
        // list of unique projects
        uniqueProjects = Array(Set(aggregatedProjects))
        
        // build dictionary of projects
        for p in uniqueProjects {
            // object to store project name, total time and color for a project
            var total_time = 0.0
            let project_name = p
            var red = 0.0
            var green = 0.0
            var blue = 0.0
            
            // for each unique project name add the total time and fetch the colors for them
            for task in projects {
                if (project_name == task.project_name && task.blue != 0.0 && task.red != 0.0 && task.green != 0.0) {
                    red = task.red
                    green = task.green
                    blue = task.blue
                }
                if p == task.project_name {
                    total_time += task.total_task_time
                }
            }
            // Save these in the Store
            store[p] = ["project_name": project_name, "total_time": total_time, "red": red, "green": green, "blue": blue]
        }
        
        // Store is now updated

        
    }
    
    // MARK: Notification Center
    
    func loadList() {
        //load data here
        var runningTask = [Project]();
        let fetchRequest =
            NSFetchRequest<Project>(entityName: "Project")
        
        do {
            projects = try managedObjectContext!.fetch(fetchRequest)
            
            let fetchRunningTaskRequest = NSFetchRequest<Project>(entityName: "Project")
            fetchRunningTaskRequest.predicate = NSPredicate(format: "is_task_running == YES")

            do {
                runningTask = try managedObjectContext!.fetch(fetchRunningTaskRequest)
                
                if runningTask.count == 0 {
                    // As this happens when the user saves a new project, we also need to let the watch know that the data has changed.
                    // This will auto update the list and stop the timer that may have been running on your apple watch. so need to think of how to tackle it differently in the future
                    // if sender is segue then run this else do not run this.
                    // but if a timer is running already, then do not send data to watch.
                    sendDataToWatch()
                }
            } catch let error as NSError {
                print("Could not fetch any running tasks. \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        setupStore()
        self.tableView.reloadData()
        }
    
    
    func timerStoppedOnPhone(notification: Notification) {
        if let userInfo = notification.userInfo, let project_name = userInfo["project_name"] as? String {
            
            if let rowForCell = self.uniqueProjects.index(of: project_name) {
                let indexPath = IndexPath(row: rowForCell, section: 0)
                let tableRow = self.tableView.cellForRow(at: indexPath) as! TasksTableViewCell
                tableRow.liveTimer.isHidden = true

                tableRow.liveTimer.text = "00:00:00"
            }
        }
        // unwrapping the session so that if it is nil then it won't call this code.
        if let watchSession = session {
            watchSession.sendMessage(["timerStoppedOnPhone": true],  replyHandler: { replyData in print("message sent") }, errorHandler: { error in print("error in sending message to phone \(error)") })
        }
        //when this message is received
        // send a message to the watch
        // the watch can then reset the interface

        
    }
    
    // WATCH MESSAGE FUNCTIONS
    
    func sendDataToWatch() {
        // unwrapping the session so that if it is nil then it won't call this code.
        if let watchsession = session {
            watchsession.sendMessage(["project": self.store, "uniqueProjects": self.uniqueProjects],
                                 replyHandler: { replyData in print("Information has been received by the watch") } ,
                                 errorHandler: { error in print("error in sending new data to watch \(error)") })
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uniqueProjects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TasksTableViewCell
        

        let project_name = uniqueProjects[indexPath.row]
        var total_time = Double()
        var red = Double()
        var green = Double()
        var blue = Double()
        
        for project in store {
            if project_name == project.key {
                total_time = project.value["total_time"] as! Double
                red = project.value["red"] as! Double
                blue = project.value["blue"] as! Double
                green = project.value["green"] as! Double

            }
        }
        
        cell.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        cell.taskName.text = project_name
        
        //check if the timer is running on the watch and for which cell item
//        then unhide the timer for that particular cell and hide for the rest
            if ProjectTimer.sharedInstance.projectName == project_name {
                cell.liveTimer.isHidden = false
            } else {
                cell.liveTimer.isHidden = true
            }

        secondsToHsMsSs(seconds: Int(total_time), result: {(hours, minutes, seconds) in
            cell.taskTime.text = "\(timeToText(s: hours))h\(timeToText(s: minutes))m\(timeToText(s: seconds))s"
        })

        return cell
    }
    

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            
            // fetching the projectName from the unique project array and then removing it.
            let project = uniqueProjects[indexPath.row]
            uniqueProjects.remove(at: indexPath.row)
            // also remove the item from the store
            store.removeValue(forKey: project)

            let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "project_name == %@", project)
            
            //fetch all items with the project name then loop through and delete them.
            do {
                let projectList = try managedObjectContext!.fetch(fetchRequest)
                for project in projectList {
                    managedObjectContext!.delete(project)
                }
                // have to save otherwise the deleted items are not removed from the db.
                try managedObjectContext!.save()
                
                // This will auto update the list and stop the timer that may have been running on your apple watch. so need to think of how to tackle it differently in the future
                var runningTask = [Project]();
                let fetchRunningTaskRequest = NSFetchRequest<Project>(entityName: "Project")
                fetchRunningTaskRequest.predicate = NSPredicate(format: "is_task_running == YES")
                
                do {
                    runningTask = try managedObjectContext!.fetch(fetchRunningTaskRequest)
                    
                    if runningTask.count == 0 {
                        sendDataToWatch()
                    }
                } catch let error as NSError {
                    print("Could not fetch any running tasks. \(error), \(error.userInfo)")
                }                
                //As this happens when the user saves a new project, we also need to let the watch know that the data has changed.
            } catch let error as NSError {
                print("unable to delete. \(error)")
            }

            //remove the row from view
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //redirect to viewTaskController
        self.performSegue(withIdentifier: "viewProject", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewProject" {
            let viewTaskViewController = segue.destination as! ViewTaskViewController
            let path = self.tableView.indexPathForSelectedRow!
            
            let taskName = uniqueProjects[(path.row)]
            var selectedTask = [String: Dictionary<String, Any>]()
            selectedTask[taskName] = store[taskName]

            
            viewTaskViewController.receivedData = selectedTask
        }

            
    }
    
    
    // THIS Reloads the table view when the user selects the back button from the detailed Project view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadList()
        tableView.reloadData()
    }

}
