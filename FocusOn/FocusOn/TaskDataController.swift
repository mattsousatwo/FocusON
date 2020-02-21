//
//  TaskDataController.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/26/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TaskDataController {

    let taskData: String = "TaskData"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    var currentTaskContainer: [TaskData] = []
    var bonusTasksContainter: [TaskData] = []
    var pastTaskContainer: [TaskData] = []
    
     init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: taskData, in: context)
    }
    
    // MARK: Save
    func saveTask(name: String = "", withGoalID UID: String) {
          
        
        let currentTask = TaskData(context: context)
            
        if name != "" {
            currentTask.name = name
        }
        
        currentTask.dateCreated = Date()
        currentTask.goal_UID = UID
        
        currentTaskContainer.append(currentTask)
        saveContext()
    }
    
    func saveBonusTask(name: String = "", withGoalID UID: String) {
        let bonusTask = TaskData(context: context)
        bonusTask.dateCreated = Date()
        bonusTask.goal_UID = UID
        if name != "" {
            bonusTask.name = name
        }
        bonusTasksContainter.append(bonusTask)
        saveContext()
    }
    
    func saveContext() {
        print(#function + "\n")
        do {
            try context.save()
        }
        catch {
        }
    }
    
    // MARK: Update
    func update(task: Tasks, from context: NSManagedObject?) {
        
    }
    
    // MARK: Fetch Tasks
    func fetchFirstTasks() -> NSManagedObject? {
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            return result.first
        }
        catch {
            
        }
        return nil
    }
    
    func fetchAllTasks() {
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
            
            do {
                currentTaskContainer = try context.fetch(request)
            }
            catch {
                
        }
        // load bonus tasks into bonusContainer
        parseBonusTasks()
    }
    
    func parseBonusTasks() {
        if currentTaskContainer.count >= 3 {
            // for task[3...MAX] append to bonusContainer
            for x in 3...currentTaskContainer.count - 1 {
                bonusTasksContainter.append(currentTaskContainer[x])
            }
        }
        print("BonusContainer = \(bonusTasksContainter.count)\n currentTaskContainer = \(currentTaskContainer.count) !&")
    }
    
    // MARK: Delete
    
    func deleteAllTasks() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskData)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
        saveContext()
    }
    
    
    
}
