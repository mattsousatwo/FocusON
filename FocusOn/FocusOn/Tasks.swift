//
//  Tasks.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//


import Foundation

class Tasks: Goal {
    
    var taskTitle: String
    let taskDate: Date
    let goal_UID: String
    let task_UID: String
    var isChecked: Bool = false
    var taskProgress: progress
    var taskColor: taskColors
    var taskNotes: String = "" 
    
    init(title: String, date: Date, goal_UID: String, task_UID: String) {
        self.taskTitle = title
        self.taskDate = date
        self.goal_UID = goal_UID
        self.task_UID = task_UID
        self.taskProgress = .beginning
        self.taskColor = .blue
        
    }
    
    // set task progress property 
    override func setProgress(to selectedIndex: Int) {
        
        switch selectedIndex {
        case 0:
            self.taskProgress = .beginning
        case 1:
            self.taskProgress = .inProgress
        case 2:
            self.taskProgress = .complete
        default:
            self.taskProgress = .beginning
        }
        
        
    }
       
    
    
    
}


enum progress {
    case beginning, inProgress, complete
}

enum taskColors {
    case blue, green, grey, pink, red, yellow
}
