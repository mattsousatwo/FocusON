//
//  Goal.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import Foundation
import CoreData

class Goal: DataController {
    
    var title: String = ""
    var date: Date // Set the date upon initalization
    var UID: String = ""
    var tasks: [Tasks] = [] // array to store each task
    var progress: progress = .beginning
    var notes: String = ""
    var markerColor: taskColors = .blue
    
    init(title: String? = "") {
        if let approvedString = title {
            self.title = approvedString
        }
        self.date = Date()
        
        super.init()
        self.UID = genID()

        if fetchAndCompare() == true { // if the next day 
            self.date = Date() // update date

        }
    }
    
    // Create a new task for a goal
    func createNew(task name: String?) {
    
        guard let taskTitle = name else {
            return
        }
        
        let newTask = Tasks(title: taskTitle, date: Date(), goal_UID: self.UID, task_UID: genID())
        
        self.tasks.append(newTask)
    }
    
    
    // set color
    func setColor(to selectedColor: taskColors) {
 
        // fetch dataSource && set color
        
        
    }
    
    func fetchAndCompare() -> Bool {
        let goalDC = GoalDataController()
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        do {
            let fetch = try goalDC.context.fetch(request)
            if fetch.count != 0 {
                let firstGoal = fetch.first!
                if goalDC.compareDays(from: firstGoal.dateCreated!) == true {
                    // The Next Day
                    return true
                } else {
                    // The Same Day
                    return false
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return false
    }
    
}


