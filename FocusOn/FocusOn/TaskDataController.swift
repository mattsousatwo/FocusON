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

class TaskDataController: GoalDataController {

    let taskData: String = "TaskData"
    var taskContext: NSManagedObjectContext
    var taskEntity: NSEntityDescription?
    
    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        taskContext = appDelegate.persistentContainer.viewContext
        taskEntity = NSEntityDescription.entity(forEntityName: taskData, in: taskContext)
    }
    
    // MARK: Save
    func saveTask(task: Tasks) {
          
        
        let currentTask = TaskData(context: context)
            
        currentTask.dateCreated = Date()
            
        
    }
    
    // MARK: Update
    func update(task: Tasks, from context: NSManagedObject?) {
        
    }
    
    // MARK: Fetch Tasks
    func fetchTasks() -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskData)
        
        do {
            let result = try taskContext.fetch(request) as! [NSManagedObject]
            return result.first
        }
        catch {
            
        }
        return nil
    }
    
    
}
