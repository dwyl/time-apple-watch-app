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

class TasksTableViewController: UITableViewController {
    
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image : UIImage = UIImage(named: "dwyl-heart-logo")!

        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        view.addSubview(imageView)
        
        self.navigationItem.titleView = view
        

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
        
        
        //fetching only unique project_names from db
//        do
//        {
//            try objects = (managedContext.fetch(request) as? [[String:AnyObject]])!
//            for object in objects! {
//                print("\(object["project_name"])")
//            }
//        }
//        catch
//        {
//            // handle failed fetch
//        }
        
        
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


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
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
//
        
        cell.backgroundColor = UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(1.0))

        cell.taskName.text = project_name
//        cell.taskTime.text = "\(hours)H\(minutes)M\(seconds)S"
        

        cell.taskTime.text = "\(total_time)"

        // Configure the cell...

        return cell
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
