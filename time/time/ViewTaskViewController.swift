//
//  ViewTaskViewController.swift
//  time
//
//  Created by Sohil Pandya on 13/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import CoreData

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
    var totalTimeInSeconds = 00

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
        task.text = project_name
        taskBackground.backgroundColor = UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(1.0))
        
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
            project.first?.total_task_time = Double(totalTimeInSeconds)
            
            
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
        
        if seconds == 59 {
            secondsLabel.text = "00"
            minutes += 1
            minutesLabel.text = String(format: "%02d", minutes)
            seconds = 00
            totalTimeInSeconds += 1
        } else {
            seconds += 1
            minutesLabel.text = String(format: "%02d", minutes)
            secondsLabel.text = String(format: "%02d", seconds)
            totalTimeInSeconds += 1
        }

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
