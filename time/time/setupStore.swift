//
//  setupStore.swift
//  time
//
//  Created by Sohil Pandya on 06/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation


//needs to take projects, unique projects and return the new store?

//func setupStore(projects: [Project], uniqueProjects: [String], store: Dictionary) {
//    
//    // SETTING UP THE STORE
//    
//    // find unique projects
//    var aggregatedProjects = [String]()
//    for p in projects {
//        aggregatedProjects.append(p.project_name!)
//    }
//    // list of unique projects
//    uniqueProjects = Array(Set(aggregatedProjects))
//    
//    // build dictionary of projects
//    for p in uniqueProjects {
//        // object to store project name, total time and color for a project
//        var total_time = 0.0
//        let project_name = p
//        var red = 0.0
//        var green = 0.0
//        var blue = 0.0
//        
//        // for each unique project name add the total time and fetch the colors for them
//        for task in projects {
//            if task.blue != 0.0 && task.red != 0.0 && task.green != 0.0 {
//                red = task.red
//                green = task.green
//                blue = task.blue
//            }
//            if p == task.project_name {
//                total_time += task.total_task_time
//            }
//        }
//        // Save these in the Store
//        store[p] = ["project_name": project_name, "total_time": total_time, "red": red, "green": green, "blue": blue]
//    }
//    
//    // Store is now updated
//    
//    
//}
