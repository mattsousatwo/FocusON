//
//  TaskData+CoreDataProperties.swift
//  FocusOn
//
//  Created by Matthew Sousa on 3/3/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var cellPosition: Int16
    @NSManaged public var dateCreated: Date?
    @NSManaged public var goal_UID: String?
    @NSManaged public var isChecked: Bool
    @NSManaged public var markerColor: Int16
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var progress: Int16
    @NSManaged public var task_UID: String?

}
