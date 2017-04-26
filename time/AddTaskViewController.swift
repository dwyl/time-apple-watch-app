//
//  AddTaskViewController.swift
//  time
//
//  Created by Sohil Pandya on 08/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var randomColors = [materialColors]()
    
    override func viewDidLoad() {
        
        
        let color1 = materialColors(red: 244.0/255.0, green: 67.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        let color2 = materialColors(red: 233.0/255.0, green: 30.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        let color3 = materialColors(red: 156.0/255.0, green: 39.0/255.0, blue: 176.0/255.0, alpha: 1.0)
        let color4 = materialColors(red: 103.0/255.0, green: 58.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        let color5 = materialColors(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        let color6 = materialColors(red: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        let color7 = materialColors(red: 3.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        let color8 = materialColors(red: 0.0/255.0, green: 188.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        let color9 = materialColors(red: 0.0/255.0, green: 150.0/255.0, blue: 136.0/255.0, alpha: 1.0)
        let color10 = materialColors(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        let color11 = materialColors(red: 139.0/255.0, green: 195.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        let color12 = materialColors(red: 205.0/255.0, green: 220.0/255.0, blue: 57.0/255.0, alpha: 1.0)
        let color13 = materialColors(red: 255.0/255.0, green: 235.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        let color14 = materialColors(red: 255.0/255.0, green: 193.0/255.0, blue: 7.0/255.0, alpha: 1.0)
        let color15 = materialColors(red: 255.0/255.0, green: 152.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        let color16 = materialColors(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        let color17 = materialColors(red: 121.0/255.0, green: 85.0/255.0, blue: 72.0/255.0, alpha: 1.0)
        let color18 = materialColors(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        let color19 = materialColors(red: 96.0/255.0, green: 125.0/255.0, blue: 139.0/255.0, alpha: 1.0)
        
        randomColors =  [color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12, color13, color14, color15, color16, color17, color18, color19]
            
        super.viewDidLoad()
        
        taskName.delegate = self
        updateSaveButtonState()
        
        let view = setNavbarLogo()
        self.navigationItem.titleView = view
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let name = taskName.text ?? ""
        let time = 12345667
        let rng = Int(arc4random_uniform(UInt32(18)))
        let red = randomColors[rng].red!
        let green = randomColors[rng].green!
        let blue = randomColors[rng].blue!
        
        print("\(red), \(green), \(blue)")
        let projectExists = doesProjectExist(name: name)
        
        if (projectExists) {
            // alert user that the name aleready exists
            print("YOU HAVE THE SAME NAME AS AN EXISTING PROJECT NAME")
            let alert = UIAlertController(title: "Name exists", message: "Oops! the project name already exists, please pick a new name", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.save(name: name, time: Double(time), red: red, green: green, blue: blue)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            dismiss(animated: true, completion: nil)
        }
        

        
    }
    
    func doesProjectExist (name: String) -> Bool {
        let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
        
        do {
            let projects = try managedObjectContext!.fetch(fetchRequest)
            var projectNameComparison = false
            
            for project in projects {
                if (project.project_name?.lowercased() == name.lowercased()) {
                    projectNameComparison = true
                }
            }
            return projectNameComparison
        } catch let error as NSError {
            print("unable to fetch. \(error)")
            return false
        }
    }
    
    func save(name: String, time: Double, red: Double, green: Double, blue: Double) {
        
        // if the task name already exists 
        // then alert user to change the name
        // otherwise continue with saving the new name. 
        // lowercase all the names when saving.
        let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
        
        do {
            let projects = try managedObjectContext!.fetch(fetchRequest)
            
            var doesProjectExist = false
            
            for project in projects {
                if (project.project_name?.lowercased() == name.lowercased()) {
                    doesProjectExist = true
                }
            }
            
            if doesProjectExist {
                // alert user that the name aleready exists
                print("YOU HAVE THE SAME NAME AS AN EXISTING PROJECT NAME")
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print("YOU HAVE ENTERED A NEW NAME")
                if let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedObjectContext!) as? Project {
                    project.project_name = name
                    project.red = red
                    project.green = green
                    project.blue = blue
                }
                do {
                    try managedObjectContext!.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
        } catch let error as NSError {
            print("unable to fetch. \(error)")
        }
        

    }

    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        //method to dismiss the view
        dismiss(animated: true, completion: nil)
        print(taskName.text!)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = taskName.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        taskName.resignFirstResponder()
        
        //potentially select the save button??
        return true
    }

}
