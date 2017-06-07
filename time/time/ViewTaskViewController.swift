//
//  ViewTaskViewController.swift
//  time
//
//  Created by Sohil Pandya on 13/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewTaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    //MARK: SETUP
    
    var receivedData = [String: Dictionary<String, Any>]()
    var project_name = String()
    var red = Double()
    var blue = Double()
    var green = Double()
    var projects: [Project] = []
    //initialise managecontextobject
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    
    @IBOutlet weak var task: UILabel!
    @IBOutlet weak var taskBackground: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var totalTimer: UILabel!
    @IBOutlet weak var listOfTasks: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        
        for project in receivedData {
            project_name = project.value["project_name"] as! String
            red = project.value["red"] as! Double
            green = project.value["green"] as! Double
            blue = project.value["blue"] as! Double
        }
        
        //TABLE RELATED
        listOfTasks.delegate = self
        listOfTasks.dataSource = self
    
        // NAVIGATION RELATED
        let navView = setNavbarLogo()
        self.navigationItem.titleView = navView
        
        // UPDATE VIEW
        task.text = project_name
        taskBackground.backgroundColor  = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        playButton.isEnabled = true
        // fetches items from database and then loads it into the view
        updateTableView(name: project_name)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: NOTIFICATIONS
    
    func subscribeToNotifications() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector:#selector(self.handleUpdateTimer), name: Notification.Name(rawValue: "TimerUpdated"), object: nil)
        notification.addObserver(self, selector: #selector(self.handleReloadTimer), name: NSNotification.Name(rawValue: "resetTimer"), object: nil)

        
    }

    @objc func handleUpdateTimer(notification: Notification) {
        if let userInfo = notification.userInfo, let timeInSeconds = userInfo["timeInSeconds"] as? Int {
            if project_name == ProjectTimer.sharedInstance.projectName {
                secondsToHsMsSs(seconds: timeInSeconds) { (hours, minutes, seconds) in
                    self.totalTimer.text = "\(timeToText(s: hours)):\(timeToText(s: minutes)):\(timeToText(s: seconds))"
                }
            }
        }
    }
    
    @objc func handleReloadTimer(notification: Notification) {
        if let userInfo = notification.userInfo, let projectName = userInfo["project_name"] as? String {
            if self.project_name == projectName {
                totalTimer.text = "00:00:00"
                playButton.isEnabled = true
            }
        }
    }
    
    
    //MARK: TIMER
    
    @IBAction func startTimer(_ sender: UIButton) {
        
        if ProjectTimer.sharedInstance.isTimerRunning() {
            let alert = UIAlertController(title: "Time is already running", message: "Oops! A timer is already running in \(ProjectTimer.sharedInstance.projectName), you can only have one timer running at a given time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            //When the user select start
            // create an item in the database and set the start_time to timeIntervalSince1970, project name and is_task_running to true
            let start_time = NSTimeIntervalSince1970
            let project_name = self.project_name
            
            ProjectTimer.sharedInstance.startTimer()
            playButton.isEnabled = false
            ProjectTimer.sharedInstance.projectName = project_name
            createTask(project_name: project_name, start_time: start_time)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "timerStartedOnPhone"), object: nil, userInfo: ["project_name": project_name, "start_time": start_time])
        }
      }

    @IBAction func stopTimer(_ sender: UIButton) {

            if ProjectTimer.sharedInstance.isTimerRunning() && project_name == ProjectTimer.sharedInstance.projectName {
                //stop the timer
                ProjectTimer.sharedInstance.stopTimer()
                //save the information to db
                saveTask()
                //reset text in view
                self.totalTimer.text = "00:00:00"
                playButton.isEnabled = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"timerStoppedOnPhone"), object: nil, userInfo: ["project_name": project_name])

            } else {
                print("you need to start a timer before stopping it! OR YOU ARE IN A DIFFERENT PROJECT")
            }
    }
    
    func createTask(project_name: String, start_time: Double) {
        // create item in database where we set the name and start time
        if let newTaskInProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext!)  as? Project {
            newTaskInProject.project_name = project_name
            newTaskInProject.start_time = Int64(start_time)
            newTaskInProject.is_task_running = true
            newTaskInProject.task_start_date = Date() as NSDate
        }
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            print("could not save newTaskInProject. \(error)")
        }
    }
    
    func saveTask() {
        let fetchRequest =
            NSFetchRequest<Project>(entityName: "Project")
        fetchRequest.predicate = NSPredicate(format: "is_task_running == YES")
        
        //3
        do {
            let project = try managedObjectContext!.fetch(fetchRequest)
            
            // now set the task end date, is task running and total task time and then save the project
            let task_start_date = project.first?.task_start_date
            let task_end_date = Date()
            let total_task_time = task_end_date.timeIntervalSince(task_start_date! as Date)
            project.first?.task_end_date = task_end_date as NSDate?
            project.first?.is_task_running = false
            project.first?.total_task_time = Double(total_task_time)
            
            
            do {
                try managedObjectContext!.save()
                updateTableView(name: project_name)
            } catch let error as NSError {
                print("unable to save project. \(error)")
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateTableView (name: String) {
        let fetchRequest =  NSFetchRequest<Project>(entityName: "Project")
        let predicate1 = NSPredicate(format: "project_name == %@", name)
        let predicate2 = NSPredicate(format: "total_task_time != 0.0")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2])

        do {
            fetchRequest.predicate = predicateCompound
            
            projects = try managedObjectContext!.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        self.listOfTasks.reloadData()
    }

    
    // TABLE VIEW

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskListTableViewCell
        
        cell.contentView.backgroundColor = UIColor.white

        let task = projects[indexPath.row]
        cell.taskName.text = task.task_name ?? task.project_name
        secondsToHsMsSs(seconds: Int(task.total_task_time), result: {(hours, minutes, seconds) in
            cell.totalTaskTime.text = "\(timeToText(s: hours))h\(timeToText(s: minutes))m\(timeToText(s: seconds))s"
        })
        
        
        return cell
        
    }

}
