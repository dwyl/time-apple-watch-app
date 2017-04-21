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

    
    override func viewDidLoad() {
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
                let red = drand48()
                let green = drand48()
                let blue = drand48()
        
        
        self.save(name: name, time: Double(time), red: red, green: green, blue: blue)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)

        dismiss(animated: true, completion: nil)
        
    }
    
    func save(name: String, time: Double, red: Double, green: Double, blue: Double) {
        
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
