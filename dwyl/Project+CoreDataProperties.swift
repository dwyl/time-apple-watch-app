//
//  Project+CoreDataProperties.swift
//  dwyl
//
//  Created by Sohil Pandya on 18/07/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var blue: Double
    @NSManaged public var end_time: Int64
    @NSManaged public var from_apple_watch: Bool
    @NSManaged public var green: Double
    @NSManaged public var id: Int16
    @NSManaged public var is_task_running: Bool
    @NSManaged public var red: Double
    @NSManaged public var start_time: Int64
    @NSManaged public var task_description: String?
    @NSManaged public var task_end_date: NSDate?
    @NSManaged public var task_name: String?
    @NSManaged public var task_start_date: NSDate?
    @NSManaged public var total_task_time: Double
    @NSManaged public var project_name: String?

}
