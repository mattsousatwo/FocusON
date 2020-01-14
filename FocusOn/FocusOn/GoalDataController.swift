//
//  DataController.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/25/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GoalDataController {
    // should i make a file for each data class?
    var entityName = "GoalData"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    
    var today: Date {
        return startOfTheDay(for: Date())
    }

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    // MARK: Save
    func saveGoal(goal: Goal) { 
        print(#function)
         
        // maybe some logic to update goal
       
        saveContext()
    }
    
    func saveContext() {
        do {
            try context.save()
        }
        catch {
        }
    }
    
    // MARK: Create
    func create() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    // MARK: Update
    func update(context: NSManagedObject?, withGoal goal: Goal) {
        if let oldGoal = context {
            oldGoal.setValue(goal, forKey: "Goal")
        }
    }
    
    // MARK: Fetch Data
    func fetchGoals() {
        
    }
    
    // MARK: Return Count
    func numberOfTasks(for: Goal) {
              
    }
       
    // MARK: Delete
    func deleteTask() {
       
    }
    
    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
               
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
               
        do {
            try context.execute(deleteRequest)
            }
        catch {
            }
    saveContext()
    }
    
    // MARK: - Time Management
    // MARK: Start of Day
    func startOfTheDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    
    // MARK: Date Caption
    
    
    
}
