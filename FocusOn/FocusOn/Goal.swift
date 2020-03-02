//
//  Goal.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import Foundation
import CoreData

class Goal {
    
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
        self.UID = genID()

        if fetchAndCompare() == true { // if the next day
            self.date = Date() // update date

        }
    } 
    
    

    
    // Generate ID - With numbers and letters
    private func genID() -> String {
        let letters = ["A", "B", "C", "D", "E", "F",
                       "G", "H", "I", "J", "K", "L",
                       "M", "N", "O", "P", "Q", "R",
                       "S", "T", "U", "V", "W", "X",
                       "Y", "Z"]
        // desired ID length
        let idLength = 5
        // tempID
        var id: String = ""
        // for 1 - idLength choose a random number
        for _ in 1...idLength {
            let x = Int.random(in: 0...10000)
            // if x is more than 5000 choose a letter
            if x >= 5000 {
                let chosenLetter = letters[Int.random(in: 0..<letters.count)]
                id += chosenLetter
            } else { // choose a number between 0 - 9
                let chosenInt = "\(Int.random(in: 0..<9))"
                id += chosenInt
            }
        }
        return id
    }
 
    
    // Create a new task for a goal
    func createNew(task name: String?) {
    
        guard let taskTitle = name else {
            return
        }
        
        let newTask = Tasks(title: taskTitle, date: Date(), goal_UID: self.UID, task_UID: genID())
        
        self.tasks.append(newTask)
    }
    
    // set Progress
    func setProgress(to selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            self.progress = .beginning
        case 1:
            self.progress = .inProgress
        case 2:
            self.progress = .complete
        default:
            self.progress = .beginning
        }
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


