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
    
    var projects: [NSManagedObject] = []
    var selectedTask: NSManagedObject!
    
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
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Project")
        
        //3
        do {
            fetchRequest.relationshipKeyPathsForPrefetching = ["tasks_list"]
            projects = try managedContext.fetch(fetchRequest)
            
        
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        
//        NotificationCenter.default.addObserver(self, selector: "loadList:", name: "load", object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    func loadList(){
        //load data here
        print("you have made it here")

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Project")
        
        //3
        do {
            projects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        

        
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
        return projects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TasksTableViewCell
        
        let project = projects[indexPath.row]
 
        cell.backgroundColor = UIColor(red: CGFloat((project.value(forKey: "red") as! Double)/255.0), green: CGFloat((project.value(forKey: "green") as! Double)/255.0), blue: CGFloat((project.value(forKey: "blue") as! Double)/255.0), alpha: CGFloat(1.0))
        
        let time = project.value(forKey: "time") as? Double
        let seconds = (time! / 1000).truncatingRemainder(dividingBy: Double(60))
        let minutes = (time! / (1000*60)).truncatingRemainder(dividingBy: Double(60))
        let hours = (time! / (1000*60*60)).truncatingRemainder(dividingBy: Double(24))

        cell.taskName.text = project.value(forKey: "name") as? String
//        cell.taskTime.text = "\(hours)H\(minutes)M\(seconds)S"
        var arr = project.value(forKey: "tasks_list")
        
        print("\(project.value(forKey: "tasks_list")), FOR KEY")
        print("\(project.value(forKeyPath: "tasks_list")), KET PATH")

        cell.taskTime.text = "\(time!)"

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
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }

            let managedContext =
                appDelegate.persistentContainer.viewContext
            

                managedContext.delete(projects[indexPath.row])
        
            projects.remove(at: indexPath.row)
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
            
            selectedTask = projects[(path.row)]
            
            viewTaskViewController.receivedData = selectedTask
        }

            
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
