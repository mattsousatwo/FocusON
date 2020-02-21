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
