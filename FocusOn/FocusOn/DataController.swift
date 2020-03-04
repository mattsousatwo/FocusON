//
//  DataController.swift
//  FocusOn
//
//  Created by Matthew Sousa on 3/2/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    
    // Generate ID - With numbers and letters
    func genID() -> String {
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
    
    
    // MARK: - Time Management
    // MARK: Start of Day
    func startOfTheDay() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: Date())
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        let endOfTheDay = Calendar.current.date(byAdding: components, to: startOfTheDay()) ?? Date()
        print("\(endOfTheDay)")
        return endOfTheDay
    }
    
    func printTimeStamps() {
        let start = startOfTheDay()
        let end = endOfDay()
        let x = end.compare(start)
        print("start: \(start), end: \(end) \n comparison: \(x.rawValue)")
    }
    
    
    func compareDays(from date1: Date) -> Bool {
        let days1 = Calendar.current.component(.day, from: date1)
        let days2 = Calendar.current.component(.day, from: endOfDay())
        let comparison = days1 - days2
        print(#function +  "\ncurrent: \(date1), endOfDay: \(endOfDay()), comparison = \(comparison)")
        print("## the actual date: \(Date())")
        if comparison >= 1 {
            // The next day
            return true
        } else {
            // The same day
            return false
        }
    }
    
    func formatDate(from goal: GoalData? = nil, from task: TaskData? = nil) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM/dd/YY"
        
        if goal != nil {
            print("goal type")
            let date = goal?.dateCreated!
            return formatter.string(from: date!)
            
        } else if task != nil {
            print("task type")
            let date = task?.dateCreated!
            return formatter.string(from: date!)
        }
        return nil
    }

    
}



enum progress {
    case beginning, inProgress, complete
}

enum taskColors {
    case blue, green, grey, pink, red, yellow
}

enum DataType {
    case goal, task, bonus
}