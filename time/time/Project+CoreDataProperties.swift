//
//  Project+CoreDataProperties.swift
//  time
//
//  Created by Sohil Pandya on 15/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var blue: Double
    @NSManaged public var green: Double
    @NSManaged public var project_name: String?
    @NSManaged public var red: Double
    @NSManaged public var total_task_time: Double
    @NSManaged public var start_time: Int64
    @NSManaged public var end_time: Int64
    @NSManaged public var task_name: String?
    @NSManaged public var task_description: String?
    @NSManaged public var id: Int16

}
