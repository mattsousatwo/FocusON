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
    var selectedTaskContainer: [TaskData] = []
    var removedTasks : [TaskData] = []
    
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
        //    saveBonusTask(withGoalID: goalUID)
        }
     //   parseBonusTasks()
    }
    
    
    // Fetch tasks for specified goal - HistoryVC
    func fetchTasksFor(goalUID: String) {
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        request.predicate = NSPredicate(format: "goal_UID = %@", goalUID)
        do {
            selectedTaskContainer = try context.fetch(request)
        } catch {
        }
        for task in selectedTaskContainer {
            if task.isRemoved == true {
                removedTasks.append(task)
                selectedTaskContainer.removeAll(where: { $0.task_UID == task.task_UID })
            }
        }
    }
    
    // Used in graph data source to get all tasks
    func fetchAllTasks() -> [TaskData] {
        var container: [TaskData] = []
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        do {
            container = try context.fetch(request)
        } catch {
        }
        return container 
    }
    
    // Fetch a single specified task
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
    
    
    func createGoalWithTasks() -> GoalData {
        let goalDC = GoalDataController()
        goalDC.deleteAll()
        deleteAllTasks()
        goalDC.saveGoal(goal: Goal(), title: "Test Goal")
        let goalID = goalDC.goalContainer.first!.goal_UID!
        for _ in 0...2 {
            
            saveTask(name: "Test Task", withGoalID: goalID)
        }
        saveBonusTask(name: "Test Bonus Cell", withGoalID: goalID)
        return goalDC.goalContainer.first(where: { $0.goal_UID! == goalID } )!
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
    
    // use task ID of task to delete
    func delete(task: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskData)
        request.predicate = NSPredicate(format: "task_UID = %@", task)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
        }
        saveContext()
    }
    
    // Delete the task from the currentTaskContainer 
    func deleteCurrentTask(at indexPath: IndexPath?, in table: UITableView) {
        guard let indexPath = indexPath else { return }
        
        table.beginUpdates()
        
        currentTaskContainer.remove(at: indexPath.row)
        
        table.deleteRows(at: [indexPath], with: .automatic)
        
        table.endUpdates()
       
        saveContext()
    }
    
    func deleteTaskFromHistory(at indexPath: IndexPath?, in table: UITableView) {
         guard let indexPath = indexPath else { return }
        let task = selectedTaskContainer[indexPath.row]
        
         table.beginUpdates()
        
         delete(task: task.task_UID!)
        
         selectedTaskContainer.remove(at: indexPath.row)
         
         table.deleteRows(at: [indexPath], with: .automatic)
         
         table.endUpdates()
        
         saveContext()
    }
    
    // Delete all goals with a goalID
    func deleteAllTasks(with goalID: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskData)
        request.predicate = NSPredicate(format: "goal_UID = %@", goalID)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
        }
        saveContext()
    }
    
    
    // Update checked property
    func updateTasks(with goalUID: String, isChecked: Bool ) {
        print(#function)
        var tasks: [TaskData] = []
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        request.predicate = NSPredicate(format: "goal_UID = %@", goalUID)
        do {
            tasks = try context.fetch(request)
        } catch {
        }
        // Change checked status
        for task in tasks {
            task.isChecked = isChecked
            print(task.task_UID! + " isChecked = \(isChecked)")
            saveContext()
        }
        
    }
    
    // Fetch tasks for specified goal - HistoryVC
    func grabTasksAssociatedWith(goalUID: String) -> [TaskData] {
        var tasks: [TaskData] = []
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        request.predicate = NSPredicate(format: "goal_UID = %@", goalUID)
        do {
            tasks = try context.fetch(request)
        } catch {
        }
        return tasks
    }
    
    
    func updateExistingTasks(in view: Views) {
        var temporaryContainer : [TaskData] = []
        print(#function)
        let request: NSFetchRequest<TaskData> = TaskData.fetchRequest()
        do {
            temporaryContainer = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch TaskData: \(error), \(error.userInfo)")
        }
        
        switch view {
        case .history:
            // seletcted
            if selectedTaskContainer.count != 0 {
                for task in selectedTaskContainer {
                    for taskT in temporaryContainer {
                        if task.task_UID == taskT.task_UID {
                            if task != taskT {
                                guard let selectedIndex = selectedTaskContainer.firstIndex(of: task) else { return }
                                task.task_UID = "123456789"
                                saveContext()
                                selectedTaskContainer.removeAll { (task) -> Bool in
                                    task.task_UID == "123456789"
                                }
                                delete(task: "123456789")
                                saveContext()
                                selectedTaskContainer.insert(taskT, at: selectedIndex)
                            }
                        }
                    }
                }
            }
            
        case .today:
            // current
            
            if currentTaskContainer.count != 0 {
                for task in currentTaskContainer {
                    for taskT in temporaryContainer {
                        if task.task_UID == taskT.task_UID {
                            if task != taskT {
                                guard let selectedIndex = currentTaskContainer.firstIndex(of: task) else { return }
                                task.task_UID = "123456789"
                                saveContext()
                                currentTaskContainer.removeAll { (task) -> Bool in
                                    task.task_UID == "123456789"
                                }
                                delete(task: "123456789")
                                saveContext()
                                currentTaskContainer.insert(taskT, at: selectedIndex)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    
}
