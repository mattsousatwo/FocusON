//
//  Goal.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

class Goal {
    
    let title: String
    let date: String // Should chamge
    let taskCount: Int
    let UID: Int
    
    init(title: String, date: String, taskCount: Int, UID: Int) {
        self.title = title
        self.date = date
        self.taskCount = taskCount
        self.UID = UID
    }

}
