//
//  ViewTaskViewController.swift
//  time
//
//  Created by Sohil Pandya on 13/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import UIKit
import CoreData

class ViewTaskViewController: UIViewController {

    
    var receivedData: NSManagedObject!
    
    @IBOutlet weak var task: UILabel!
    @IBOutlet weak var taskBackground: UIView!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var tasks: [NSManagedObject] = []

    var timer = Timer()
    var seconds = 00
    var minutes = 00
    var isRunning = false
    var totalTimeInSeconds = 00

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "dwyl-heart-logo")!
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        view.addSubview(imageView)
        
        self.navigationItem.titleView = view

    
        task.text = receivedData.value(forKey: "name") as! String?
        taskBackground.backgroundColor = UIColor(red: CGFloat((receivedData.value(forKey: "red") as! Double)/255.0), green: CGFloat((receivedData.value(forKey: "green") as! Double)/255.0), blue: CGFloat((receivedData.value(forKey: "blue") as! Double)/255.0), alpha: CGFloat(1.0))
        
        secondsLabel.text = String(format: "%02d", seconds)
        minutesLabel.text = String(format: "%02d", minutes)
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        isRunning = false
      
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        

        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Task")
        let name = receivedData.value(forKey: "name") as! String
        let predicate = NSPredicate(format: "project_name.name = %@", name)
        

        //3
        do {
//            fetchRequest.predicate = predicate
            tasks = try managedContext.fetch(fetchRequest)

            for task in tasks {
                print("\(task.value(forKey: "total_time"))")
                print("\(task.value(forKeyPath: "project_name"))")

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        print("YOU IN HERE")
        print("\(isRunning)")
        if !isRunning {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewTaskViewController.updateTimer), userInfo: nil, repeats: true)
            
            playButton.isEnabled = false
            pauseButton.isEnabled = true
            isRunning = true
        }
    }

    
    @IBAction func pauseTimer(_ sender: UIButton) {
        
        playButton.isEnabled = true
        pauseButton.isEnabled = false
        timer.invalidate()
        isRunning = false
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        
        isRunning = false
        timer.invalidate()
        
        print("\(totalTimeInSeconds)")
        
        //save to database
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
            }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: managedContext) as? Task {
            task.total_time = Int32(totalTimeInSeconds)
            task.project_name = receivedData as! Project?
        }
        
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("could not save. \(error), \(error.userInfo)")
        }
                
        seconds = 00
        minutes = 00
        secondsLabel.text = String(format: "%02d", seconds)
        minutesLabel.text = String(format: "%02d", minutes)
        playButton.isEnabled = true
        pauseButton.isEnabled = false
    }
    
    func updateTimer () {
        
        if seconds == 5 {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
