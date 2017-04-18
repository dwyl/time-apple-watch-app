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


    
    var receivedData = [String: Dictionary<String, Any>]()
    var project_name = String()
    var red = Double()
    var blue = Double()
    var green = Double()
    
    @IBOutlet weak var task: UILabel!
    @IBOutlet weak var taskBackground: UIView!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var listOfTasks: UITableView!
    var projects: [Project] = []

    var timer = Timer()
    var seconds = 00
    var minutes = 00
    var isRunning = false
    var isTimerRunningOnWatch = false
    
    var watchTimer = Timer()
    

    //initialise managecontextobject
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for project in receivedData {
            print("in for loop\(project.value["project_name"])")
            project_name = project.value["project_name"] as! String
            red = project.value["red"] as! Double
            green = project.value["green"] as! Double
            blue = project.value["blue"] as! Double
        }
        
        
        // if a user stops the timer on the watch
        // send a notification from tableview to this detailed view
        // reset the timer.
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimerOnPhone), name: NSNotification.Name(rawValue:"stopPhoneTimer"), object: nil)
        
        
        //TABLE RELATED
        listOfTasks.delegate = self
        listOfTasks.dataSource = self
        
        // NAVIGATION RELATED
        let image : UIImage = UIImage(named: "dwyl-heart-logo")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.addSubview(imageView)
        self.navigationItem.titleView = view
        
        
        // UPDATE VIEW

        print("\(project_name)")
        isTaskRunningOnWatch(project_name: project_name)

        task.text = project_name
        taskBackground.backgroundColor  = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
        
        secondsLabel.text = String(format: "%02d", seconds)
        minutesLabel.text = String(format: "%02d", minutes)
        playButton.isEnabled = true
        isRunning = false
      
        // fetches items from database and then loads it into the view
        updateTableView(name: project_name)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    NotificationCenter.default.addObserver(self, selector: #selector(resetTimerForPhone), name: NSNotification.Name(rawValue: "stopPhoneTimer"), object: nil)
    
    
    
    
    // MARK: Timer
    
    // If a timer was started on the watch, the timer should represent that time.
    
    // fetch the list of tasks that are currently running on the watch for this given project.
    func isTaskRunningOnWatch (project_name: String) {
        print("You are in isTaskRunningOnWatch <<<<<< \(project_name)")
        let fetchRequest = NSFetchRequest<Project>(entityName:"Project")
        let predicate1 = NSPredicate(format: "project_name == %@", project_name)
        let predicate2 = NSPredicate(format: "from_apple_watch == YES")
        let predicate3 = NSPredicate(format: "is_task_running == YES")
        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2, predicate3])
        
        do {
            fetchRequest.predicate = predicateCompound
            
            let project = try self.managedObjectContext!.fetch(fetchRequest)
            
            if (project.count == 1) {
                for p in project {
                    
                    // if a project is returned
                    // we need to capture the time difference
                    let start_time = p.task_start_date!
                    let end_time = Date() as NSDate
                    //roudning the total time
                    let total_time = CFDateGetTimeIntervalSinceDate(end_time, start_time).rounded()
                    seconds = Int(total_time)
                    // start the timer from the time difference
                    watchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                    // enable stop button and disable play button
                    playButton.isEnabled = false
                    
                    // This needs to send a message to the watch so that 
                    // we can stop the timer for that given project
                    stopButton.isEnabled = true
                    isTimerRunningOnWatch = true
                }
            
            }
        } catch let error as NSError {
            print("Error, not fetched the data from CoreData \(error.userInfo)")
        }
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        
        let start_time = NSTimeIntervalSince1970
        let project_name = self.project_name
        //When the user select start
        // create an item in the database and set the start_time to timeIntervalSince1970, project name and is_task_running to true
        createTask(project_name: project_name, start_time: start_time)
        
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewTaskViewController.updateTimer), userInfo: nil, repeats: true)
            
            playButton.isEnabled = false
            isRunning = true
        }
    }

    func createTask(project_name: String, start_time: Double) {
        // create item in database where we set the name and start time
        if let newTaskInProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext!)  as? Project {
            newTaskInProject.project_name = project_name
            newTaskInProject.start_time = Int64(start_time)
            newTaskInProject.is_task_running = true
        }
        
        do {
            try managedObjectContext?.save()
        } catch let error as NSError {
            print("could not save newTaskInProject. \(error)")
        }
    }
    
    
    @IBAction func pauseTimer(_ sender: UIButton) {
        
        playButton.isEnabled = true
        timer.invalidate()
        isRunning = false
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        
        
        if (isTimerRunningOnWatch) {
            // run this if the timer was started on the watch
            // send the information over to the core database
            let fetchRequest =
                NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "is_task_running == YES")
            do {
                let project = try managedObjectContext!.fetch(fetchRequest)
                print("\(project)")
                print("\(project.count)<<<<<<<<")
                // now set the task end date, is task running and total task time and then save the project
                let task_end_date = Date()
                project.first?.task_end_date = task_end_date as NSDate?
                project.first?.is_task_running = false
                project.first?.total_task_time = Double(seconds)
                
                
                do {
                    try managedObjectContext!.save()
                    updateTableView(name: project_name)
                } catch let error as NSError {
                    print("unable to save project. \(error)")
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }

            
            // if the user decides to stop the watch timer on the phone
            // send a notification to the app view controller
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"timerStoppedOnPhone"), object: nil)
            // which can then inturn send a message to the apple watch
            // that can reset the time on the watch
            
            // stop the timer and reset evertything on this page
            stopTimerOnPhone()
            
        } else {
            
            isRunning = false
            timer.invalidate()
            //find the existing item in the database which has a is_task_running for the given project
            
            let fetchRequest =
                NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "is_task_running == YES")
            
            //3
            do {
                let project = try managedObjectContext!.fetch(fetchRequest)
                
                // now set the task end date, is task running and total task time and then save the project
                let task_end_date = Date()
                project.first?.task_end_date = task_end_date as NSDate?
                project.first?.is_task_running = false
                project.first?.total_task_time = Double(seconds)
                
                
                do {
                    try managedObjectContext!.save()
                    updateTableView(name: project_name)
                } catch let error as NSError {
                    print("unable to save project. \(error)")
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            seconds = 00
            minutes = 00
            secondsLabel.text = String(format: "%02d", seconds)
            minutesLabel.text = String(format: "%02d", minutes)
            playButton.isEnabled = true
            
        }

    }
    
    func updateTableView (name: String) {
        let fetchRequest =  NSFetchRequest<Project>(entityName: "Project")
//        let predicate = NSPredicate(format: "any project_name = %@", name)
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
    
    func updateTimer () {
        seconds += 1
        secondsLabel.text = String(format: "%02d", (seconds % 3600) % 60)
        minutesLabel.text = String(format: "%02d", (seconds % 3600) / 60)
    }
    
    func stopTimerOnPhone () {
        print("Timer stoped on the Watch")
        watchTimer.invalidate()
        seconds = 00
        secondsLabel.text = String("00")
        minutesLabel.text = String("00")
        playButton.isEnabled = true
        stopButton.isEnabled = false
        isTimerRunningOnWatch = false
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
        
        let task = projects[indexPath.row]
        
        cell.taskName.text = task.task_name ?? task.project_name
        secondsToHsMsSs(seconds: Int(task.total_task_time), result: {(hours, minutes, seconds) in
            cell.totalTaskTime.text = "\(timeToText(s: hours))h\(timeToText(s: minutes))m\(timeToText(s: seconds))s"
        })
        
        
        return cell
        
    }

}
