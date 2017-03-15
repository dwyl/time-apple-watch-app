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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskName.delegate = self
        updateSaveButtonState()
        
        let image : UIImage = UIImage(named: "dwyl-heart-logo")!
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        view.addSubview(imageView)
        
        self.navigationItem.titleView = view
        // Do any additional setup after loading the view.
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        print("KKKKKK")
        let name = taskName.text ?? ""
                let time = 12345667
                let red = 123.0
                let green = 223.0
                let blue = 34.0
        
        
        self.save(name: name, time: Double(time), red: red, green: green, blue: blue)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)

        dismiss(animated: true, completion: nil)
        
    }
    
    
    func save(name: String, time: Double, red: Double, green: Double, blue: Double) {
        print("dsadasd")
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        print("\(managedContext), CONTEXT")
        // 2
        
        if let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as? Project {
            
            project.name = name
            project.time = time
            project.red = red
            project.green = green
            project.blue = blue
        }
//        
//        let entity =
//            NSEntityDescription.entity(forEntityName: "Project",
//                                       in: managedContext)!
//        print("\(entity), ENTITY")
//        let project = NSManagedObject(entity: entity,
//                                     insertInto: managedContext)
//        
//        // 3
//        project.setValue(name, forKeyPath: "name")
//        project.setValue(time, forKeyPath: "time")
//        project.setValue(red, forKeyPath: "red")
//        project.setValue(green, forKeyPath: "green")
//        project.setValue(blue, forKeyPath: "blue")
        
        // 4
        do {
            try managedContext.save()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
