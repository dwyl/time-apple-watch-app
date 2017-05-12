//
//  startLiveTimerOnScreenIfRunning.swift
//  dwyl time
//
//  Created by Sohil Pandya on 12/05/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation
import CoreData


func startLiveTimerOnScreenIfRunning(managedObjectContext: NSManagedObjectContext) -> (Bool, String) {
    let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
    fetchRequest.predicate = NSPredicate(format: "is_task_running == YES")
    do {
        let runningtask = try managedObjectContext.fetch(fetchRequest)
        
        if runningtask.count == 0 {
            return (false, "")
        } else {
            return (true, (runningtask.first?.project_name)!)
        }
        
        
    } catch let error as NSError {
        print("oops, unable to fetch information \(error.userInfo)")
    }

    return(false, "")
}


//let fetchRequest =
//    NSFetchRequest<Project>(entityName: "Project")
//
//do {
//    projects = try managedObjectContext!.fetch(fetchRequest)
//    
//    let fetchRunningTaskRequest = NSFetchRequest<Project>(entityName: "Project")
//    fetchRunningTaskRequest.predicate = NSPredicate(format: "is_task_running == YES")
//    
//    do {
//        runningTask = try managedObjectContext!.fetch(fetchRunningTaskRequest)
//        
//        if runningTask.count == 0 {
//            // As this happens when the user saves a new project, we also need to let the watch know that the data has changed.
//            // This will auto update the list and stop the timer that may have been running on your apple watch. so need to think of how to tackle it differently in the future
//            // if sender is segue then run this else do not run this.
//            // but if a timer is running already, then do not send data to watch.
//            sendDataToWatch()
//        } else {
//            isTimerRunningOnWatch = true
//        }
//    } catch let error as NSError {
//        print("Could not fetch any running tasks. \(error), \(error.userInfo)")
//    }
//} catch let error as NSError {
//    print("Could not fetch. \(error), \(error.userInfo)")
//}
