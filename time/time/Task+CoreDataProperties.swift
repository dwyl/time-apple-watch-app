//
//  Task+CoreDataProperties.swift
//  time
//
//  Created by Sohil Pandya on 14/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task");
    }

    @NSManaged public var name: String?
    @NSManaged public var total_time: Int32
    @NSManaged public var start_time: Double
    @NSManaged public var end_time: Double
    @NSManaged public var project_name: Project?

}
