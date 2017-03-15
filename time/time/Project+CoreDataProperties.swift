//
//  Project+CoreDataProperties.swift
//  time
//
//  Created by Sohil Pandya on 14/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var blue: Double
    @NSManaged public var green: Double
    @NSManaged public var name: String?
    @NSManaged public var red: Double
    @NSManaged public var time: Double
    @NSManaged public var tasks_list: NSSet?

}

// MARK: Generated accessors for tasks_list
extension Project {

    @objc(addTasks_listObject:)
    @NSManaged public func addToTasks_list(_ value: Task)

    @objc(removeTasks_listObject:)
    @NSManaged public func removeFromTasks_list(_ value: Task)

    @objc(addTasks_list:)
    @NSManaged public func addToTasks_list(_ values: NSSet)

    @objc(removeTasks_list:)
    @NSManaged public func removeFromTasks_list(_ values: NSSet)

}
