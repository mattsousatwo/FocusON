//
//  Enumerations.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/24/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation

enum DisplayMode: String {
    case goalMode = "Display: GoalMode\n", taskMode = "Display: TaskMode\n"
}

enum DeletedTaskMode: String {
    case goal = "lastDeletedType = Goal", task = "lastDeletedType = Task", deleteAll = "lastDeletedType = DeleteAll"
}

enum Views: String {
    case today = "Today View" , history = "History View"  
}

enum progress {
    case beginning, inProgress, complete
}

enum taskColors: Int16 {
    case blue = 0 , green, grey, pink, red, yellow
}

enum DataType {
    case goal, task, bonus
}

