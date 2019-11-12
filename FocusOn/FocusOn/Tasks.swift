//
//  Tasks.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

class Tasks {
    
    let title: String
    let date: String
    let goal_UID: Int
    let UID: Int
    
    init(title: String, date: String, goal_UID: Int, UID: Int) {
        self.title = title
        self.date = date
        self.goal_UID = goal_UID
        self.UID = UID
    }
}
