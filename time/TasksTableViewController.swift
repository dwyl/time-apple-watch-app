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

//// MARK: WCSessionDelegate
//extension TasksTableViewController: WCSessionDelegate {
//    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
//   }


class TasksTableViewController: UITableViewController, WCSessionDelegate {
    

    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    var projects: [Project] = []
    var objects:[[String:AnyObject]]?
    var projectNames = [String]()
    var uniqueProjects = [String]()
    var store = [String: Dictionary<String, Any>]()
    /*
     
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
    
//    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    
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

    
    //PHONE
    
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        //Dummy Implementation
        print("")
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        //Dummy Implementation
        print("")
    }
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        //Dummy Implementation
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        DispatchQueue.main.async {
            if (message["project"] as? Int) != nil {
                replyHandler(["project": self.store , "uniqueProjects": self.uniqueProjects])
            }
            if (message["startTimerFor"] as? String) != nil {
                
                // save the given item to the coredata create a new field called fromAppleWatch which we have to set to true here. 
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                if let newTaskInProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext)  as? Project {
                    // setting from apple watch to true as this comes from the apple watch
                    newTaskInProject.from_apple_watch = true
                    newTaskInProject.project_name = message["startTimerFor"] as! String?
                    newTaskInProject.start_time = Int64(NSTimeIntervalSince1970)
                    newTaskInProject.is_task_running = true
                    
                }
                // 4
                do {
                    try managedContext.save()
                    replyHandler(["savedToCoreData": true])
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }

            }
            if (message["stopTimerFor"] as? String) != nil {
                
                let project_name = message["stopTimerFor"] as! String?
                let total_task_time = message["total_task_time"] as! Double
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                
                let fetchRequest =  NSFetchRequest<Project>(entityName: "Project")
                //        let predicate = NSPredicate(format: "any project_name = %@", name)
                let predicate1 = NSPredicate(format: "project_name == %@", project_name!)
                let predicate2 = NSPredicate(format: "is_task_running == YES")
                let predicate3 = NSPredicate(format: "from_apple_watch == YES")
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2,predicate3])
                
                do {
                    fetchRequest.predicate = predicateCompound
                    
                    let project = try managedContext.fetch(fetchRequest)
                    for p in project {
                        print("\(p.total_task_time), \(p.task_name)")
                    }
                    
                    print("\(project)<<<< THIS IS THE PROJECT FETCHED FROM COREDATA")
                    // now set the task end date, is task running and total task time and then save the project
                    let task_end_date = Date()
                    project.first?.task_end_date = task_end_date as NSDate?
                    project.first?.is_task_running = false
                    project.first?.total_task_time = Double(total_task_time)
                    
                    
                    do {
                        self.loadList()
                        replyHandler(["savedToCoreData": "YOU SAVED TO THE DB"])
                        try managedContext.save()
                        
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
    
    
//  Dummy alert function that's job is to show a pop up.
    func sayHi(){
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "dwyl-heart-logo")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.addSubview(imageView)
        self.navigationItem.titleView = view
        
         configureWCSession()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
//        let projects = Project.fetchListOfProjectsFromDatabase(inManagedObjectContext: self.managedObjectContext!)
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity( forEntityName: "Project",  in:managedContext )
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entity
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = [ "project_name" ]
        
        let fetchRequest =
            NSFetchRequest<Project>(entityName: "Project")
        
//         fetching all information from the db
        do {
            projects = try managedContext.fetch(fetchRequest)

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // SETTING UP THE STORE
        setupStore()

        // create a listerner that will reload the list if a new project is added to the list
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
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
                if task.blue != 0.0 && task.red != 0.0 && task.green != 0.0 {
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
    
    func loadList(){
        //load data here
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<Project>(entityName: "Project")
        
        //3
        do {
            projects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        setupStore()
        self.tableView.reloadData()
        
        //As this happens when the user saves a new project, we also need to let the watch know that the data has changed.
        // This will auto update the list and stop the timer that may have been running on your apple watch. so need to think of how to tackle it differently in the future
//        if sender is segue then run this else do not run this. 
        sendDataToWatch()
        }
    
    // WATCH MESSAGE FUNCTIONS
    
    func sendDataToWatch() {
        print("\(store)")
        print("\(uniqueProjects)")

        session!.sendMessage(["project": self.store, "uniqueProjects": self.uniqueProjects],
                             replyHandler: { replyData in print("Got it?") } ,
                             errorHandler: { error in print("error in sending new data to watch \(error)") })
  
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
        
        cell.backgroundColor = UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(1.0))

        cell.taskName.text = project_name
        let seconds = (total_time.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60)
        let minutes = (total_time.truncatingRemainder(dividingBy: 3600)) / 60
        let hours = (total_time / 3600)
        print("\(total_time)totalTime")
        print("\(hours)HH\(minutes)MM\(seconds)SS")

        secondsToHsMsSs(seconds: Int(total_time), result: {(hours, minutes, seconds) in
            cell.taskTime.text = "\(self.timeToText(s: hours))h\(self.timeToText(s: minutes))m\(self.timeToText(s: seconds))s"
        })
        


        return cell
    }
    
    func timeToText(s: Int) -> String {
        return s < 10 ? "0\(s)" : "\(s)"
    }
    
    func secondsToHsMsSs(seconds : Int, result: @escaping (Int, Int, Int)->()) {
        result(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            
            // fetching the projectName from the unique project array and then removing it.
            let project = uniqueProjects[indexPath.row]
            uniqueProjects.remove(at: indexPath.row)
            // also remove the item from the store
            store.removeValue(forKey: project)

            
            // delete all instances of the project from the db
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "project_name == %@", project)
            
            //fetch all items with the project name then loop through and delete them.
            do {
                let projectList = try managedContext.fetch(fetchRequest)
                for project in projectList {
                    managedContext.delete(project)
                }
                // have to save otherwise the deleted items are not removed from the db.
                try managedContext.save()
                
                // This will auto update the list and stop the timer that may have been running on your apple watch. so need to think of how to tackle it differently in the future
                sendDataToWatch()
                
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
