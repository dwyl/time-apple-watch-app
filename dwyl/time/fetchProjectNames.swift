//
//  fetchProjectNames.swift
//  time
//
//  Created by Sohil Pandya on 06/04/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import CoreData

func fetchProjectNames(managedObjectContext: NSManagedObjectContext) -> [Project] {
    let entity = NSEntityDescription.entity( forEntityName: "Project",  in:managedObjectContext )
    let request = NSFetchRequest<NSFetchRequestResult>()
    request.entity = entity
    request.resultType = .dictionaryResultType
    request.returnsDistinctResults = true
    request.propertiesToFetch = [ "project_name" ]
    
    let fetchRequest =
        NSFetchRequest<Project>(entityName: "Project")
    
    var projects = [Project]()
    
    //         fetching all information from the db
    do {
        projects = try managedObjectContext.fetch(fetchRequest)

    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    return projects

}
