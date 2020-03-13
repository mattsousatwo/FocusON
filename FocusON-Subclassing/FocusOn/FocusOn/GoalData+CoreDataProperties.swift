//
//  GoalData+CoreDataProperties.swift
//  FocusOn
//
//  Created by Matthew Sousa on 2/11/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
//

import Foundation
import CoreData


extension GoalData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoalData> {
        return NSFetchRequest<GoalData>(entityName: "GoalData")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var goal_UID: String?
    @NSManaged public var isChecked: Bool
    @NSManaged public var markerColor: Int16
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var progress: Int16

}
