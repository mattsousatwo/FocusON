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

class TaskDataController: DataController {

    let taskData: String = "TaskData"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    var currentTaskContainer: [TaskData] = []
    var bonusTasksContainter: [TaskData] = []
    var pastTaskContainer: [TaskData] = []
    
     override init() {
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
        currentTask.task_UID = genID()
        
        
        print("SAVING TASK - \(currentTask.task_UID ?? "No ID Set")")
        
        currentTaskContainer.append(currentTask)
        saveContext()
    }
    
    func saveBonusTask(name: String = "", withGoalID UID: String, atPos position: Int16? = 0) {
        let bonusTask = TaskData(context: context)
        bonusTask.dateCreated = Date()
        bonusTask.goal_UID = UID
        bonusTask.task_UID = genID()
        guard let cellPosition = position else { return }
        bonusTask.cellPosition = cellPosition
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
    // Fetch all tasks for goal
    func fetchTasks(with goalUID: String = "") {  
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        if goalUID != "" {
            request.predicate = NSPredicate(format: "goal_UID = %@", goalUID)
        }
        do {
            currentTaskContainer = try context.fetch(request)
        }
        catch {
        }
        // If taskContainer is empty { create three tasks } 
        if currentTaskContainer.count == 0 {
            for _ in 1...3 {
                saveTask(withGoalID: goalUID)
            }
        }
        parseBonusTasks()
    }
    
    // Fetch specified task
    func fetchTask(with goalUID: String) -> TaskData {
        var task: [TaskData] = []
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        request.predicate = NSPredicate(format: "task_UID = %@", goalUID)
        do {
            task = try context.fetch(request)
        }
        catch {
            print("Could not fetch task ")
        }
        return task.first!
    }
    
        // not sure if i still need this func
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
    
    // to seperate tasks - if task.count >3 append tasks into bonus container
    func parseBonusTasks() {
        if currentTaskContainer.count >= 4 {
            // for task[3...MAX] append to bonusContainer
            for x in 4...currentTaskContainer.count - 1 {
                bonusTasksContainter.append(currentTaskContainer[x])
            }
        }
        print("BonusContainer = \(bonusTasksContainter.count)\n currentTaskContainer = \(currentTaskContainer.count) !&")
    }
    
    // Display Tasks in saved order.
    func distrubuteTasks() {
        if currentTaskContainer.count != 0 {
            for task in currentTaskContainer {
                // accesing specified task index
                guard let currentIndex  = currentTaskContainer.firstIndex(of: task) else { return }
                // if taskSavedPosition is equal to currentIndex
                if task.cellPosition != currentIndex {
                    // convert Int16 position to Int
                    let newPos = Int(task.cellPosition)
                    // insert into current TaskContainer
                    currentTaskContainer.insert(task, at: newPos)
                        
                }
            
            }
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
