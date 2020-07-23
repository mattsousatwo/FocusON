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

class GoalDataController: DataController {
    
    var entityName = "GoalData"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    var goalContainer: [GoalData] = []
    var currentGoal = GoalData()
    var pastGoalContainer: [GoalData] = []
    let taskDC = TaskDataController()
    var removedGoals: [GoalData] = []

    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    // MARK: Save

    // Save Managed Context
    func saveContext() {
        print(#function + "\n")
        do {
            try context.save()
        }
        catch {
        }
    }
    
    // Create a new goal
    func createNewGoal(title: String = "", date: Date? = nil) {
        // create goal
        let goal = GoalData(context: context)
        
        // assign UID
        goal.goal_UID = genID()
        
        // assign date
        if let date = date {
            goal.dateCreated = date
        } else {
            goal.dateCreated = Date()
        }
        
        // Set title
        goal.name = title
        
        // Show goal
        goal.isRemoved = false
        
        // append to goal container
        goalContainer.append(goal)
        saveContext()
    }
    
    // MARK: Create
    // Creating goals for testing
    func createTestGoals(int: Int = 5, month: Int = 1) {
        // if goal does not equal default value or 0
        if int != 5 && int != 0 && month != 1 {
            // create defined amount of test goals
            for x in 1...int {
                let date = createDate(month: month, day: x, year: 2020)
                createNewGoal(title: "HELLO WORLD \(x)", date: date)
                
            }
        } else {
            // create Five test goals
            for x in 1...5 {
                let date = createDate(month: 1, day: x, year: 2020)
                createNewGoal(title: "HELLO WORLD \(x)", date: date)
            }
        }
    }
    

    
    // MARK: Fetch
    // get and return the title for an entity by the UID
    func fetchGoal(withUID UID: String ) -> GoalData {
        var xGoal = GoalData()
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        request.predicate = NSPredicate(format: "goal_UID = %@", UID)
        do {
            let goalArray = try context.fetch(request)
            let goal = goalArray.first!
            xGoal = goal
        } catch let error as NSError {
            print("Could not return title for goal with UID: \(UID), error: \(error), \(error.userInfo)")
        }
        
        return xGoal
        
    }
    
    // return an array of all the goals for ProgressVC
    func fetchAllGoals() -> [GoalData] {
        var array: [GoalData] = []
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        do {
            array = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch GoalData: \(error), \(error.userInfo)")
        }
        return array
    }
       
    // MARK: Delete
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
    
    
    
    // MARK: getGoals() -
    // New Fetch Goals method - May 27
    func getGoals() {
        
            goalContainer.removeAll()
        
        printOne(#function + " --- start")
        // Fetch goals
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        do {
            goalContainer = try context.fetch(request)
            
        } catch let error as NSError {
            print("Could not fetch GoalData: \(error), \(error.userInfo)")
        }
        
        // Parse goal container for current goal
        switch goalContainer.count != 0 {
        case true:
            printOne(#function + " container.count != 0: TRUE")
            // Goal Container has goals
            parseGoals()
        case false:
            printOne(#function + "container.count != 0: FALSE")
            // Goal Container is empty
            // Check if currentGoal is in pastGoalContainer
            compareCurrentGoalToPastGoals() // maybe just need to create a new goal and not compare - if goalContainer is empty so is pastGoals
        }
        printOneOutcome()
        printOne(#function + " --- end")
    }
    
    
    // Seperate CurrentGoals VS PastGoals
    func parseGoals() {
        printOne(#function)
        // seperate current and past goals
        sortThroughDates()
        // hide all goals that are marked as removed and store in Removed Goals
        hideRemovedGoals()
        // sorting past goals by date
        sortPastGoalsByDate()
    }
    
    // Sift through goal Container for any goals that are removed and store them in removedGoals
    func hideRemovedGoals() {
        if pastGoalContainer.count != 0 {
            for goal in pastGoalContainer {
                if goal.isRemoved == true {
                    removedGoals.append(goal)
                    pastGoalContainer.removeAll(where: { $0.goal_UID == goal.goal_UID } )
                    removedGoals.sort(by: {
                        $0.timeRemoved! > $1.timeRemoved!
                    })
                }
            }
        }
    }
    
    // Delete Goals - use pastGoalUIDs to get array of past goals to delete 
    func deleteGoalsWith(UIDs tags: [String]) {
        for tag in tags {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "goal_UID = %@", tag)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            do {
                try context.execute(deleteRequest)
            } catch {
            }
            saveContext()
        }
    }
    
    // Print func for tests
    func printOne(_ string: String) {
        let message = "Test 101 "
        let totalMessage = message + string
        print(totalMessage)
    }
    
    // print total count of containers
    func printOneOutcome(_ string: String? = "") {
        var totalMessage = ""
        let tag = "Test 101 - TOTAL - "
        let current = "currentGoal.UID: \(currentGoal.goal_UID!),"
        let gContainer = " goalContainer.count: \(goalContainer.count),"
        let pContainer = " pastGoalContainer.count: \(pastGoalContainer.count)"
        let total = " - TOTAL GOALS = \(goalContainer.count + pastGoalContainer.count)"
        if let input = string {
            totalMessage = tag + current + gContainer + pContainer + total + input
        } else {
            totalMessage = tag + current + gContainer + pContainer + total
        }
        print(totalMessage)
    }
    
    // check if currentGoal is in pastGoalContainer
    func compareCurrentGoalToPastGoals() {
        printOne(#function + " --- start")
        var status: Bool = false
        for goal in pastGoalContainer {
            if currentGoal == goal {
                printOne("currentGoalUID = \(currentGoal.goal_UID!), currentGoal.text = \(currentGoal.name!) ")
                status = true
            }
        }
        switch status {
        case true:
            printOne("status: true, goal is in pastGoals")
        case false:
            createNewCurrentGoal()
        }
        printOne(#function + " --- end")
    }
    
    // If day passes and current goal is not complete refactor goal for new day, else create new goal
    func useLastGoalIfIncomplete() { 
        // get most recent goal
        sortPastGoalsByDate()
        guard let mostRecentGoal = pastGoalContainer.first else { return }
        
        print("Test 202: most recent goal = \(mostRecentGoal.goal_UID!) \(mostRecentGoal.dateCreated!)")
        switch mostRecentGoal.isChecked {
        case true:
            // most recent goal is completed
                // create a new goal for today
                // clear array
            print("Test 202: goal is checked -> create a new goal for the day")
            pastGoalContainer.append(mostRecentGoal)
            createNewCurrentGoal()
        case false:
            print("Test 202: goal is unchecked -> move most recent goal to today")
            // save old UID
            guard let oldUID = mostRecentGoal.goal_UID else { return }
            // Create new UID
            let newID = genID()
            // update tasks with new UID
            let tasks = taskDC.grabTasksAssociatedWith(goalUID: oldUID)
            for task in tasks {
                task.goal_UID = newID
                taskDC.saveContext()
            }
            // Change goals uid
            mostRecentGoal.goal_UID = newID
            // Change goals date to today
            mostRecentGoal.dateCreated = Date()
            // Set as current goal
            currentGoal = mostRecentGoal
            
            // remove from pastGoals
            pastGoalContainer.removeAll { (goal) -> Bool in
                goal.goal_UID == oldUID
            }
            // Delete goal with old uid
            deleteGoalsWith(UIDs: [oldUID])
            // save goal context
            saveContext()

        }
        
        
        
    }
    
    // Sort goals by their dates into pastGoalContainer or if from today set as currentGoal
    func sortThroughDates() {
        printOne(#function + " --- start")
        for goal in goalContainer {
            if isDateFromToday(goal.dateCreated) == false { // if goal is NOT from today
                
                printOne("isDateFromToday(goal.dateCreated) == false { add to goal && remove }")
                // move to past container
                pastGoalContainer.append(goal)
                printOne("pastGoalContainer.count = \(pastGoalContainer.count) [  B ]")
                // remove goal from goal container
                goalContainer.removeAll(where: { $0.goal_UID == goal.goal_UID! })
                printOne("goalUID == \(goal.goal_UID!)")
                printOne("goalContainer.count = \(goalContainer.count) [  B ]")
                if goalContainer.count == 0 {
                    useLastGoalIfIncomplete()
//                    createNewCurrentGoal()
                }
            } else if isDateFromToday(goal.dateCreated) == true {
                // if currentGoal is from today set as current goal
                printOne("isDateFromToday(goal.dateCreated) == true { set as current goal }")
                printOne("goalUID == \(goal.goal_UID!)")
                currentGoal = goal
            }
            
        }
        printOne(#function + " --- end")
    }
    
    // Make sure pastGoalContainers goals are in order by date
    func sortPastGoalsByDate() {
        pastGoalContainer.sort { (goalA, goalB) -> Bool in
            goalA.dateCreated! > goalB.dateCreated!
        }
    }
    
    // Organize removed goals by timeRemoved
    func sortRemovedGoalsByTimeRemoved() {
        removedGoals.sort { (goalA, goalB) -> Bool in
            goalA.timeRemoved! > goalB.timeRemoved!
        }
    }
    
    // Create new goal and set it as current goal
    func createNewCurrentGoal() {
        printOne(#function + " --- start")
        printOne("goalContainer.count = \(goalContainer.count) [   C ]")
        createNewGoal()
//        saveGoal(goal: Goal())
        currentGoal = goalContainer.first!
        printOne("goalContainer.count = \(goalContainer.count) [    D ]")
        // Maybe should remove goal after adding
        printOne(#function + " --- end")
    }
    
    
    // Hide Goal and store in removed goals - refresh table after call
    func remove(goal: GoalData) {
        print("removeGoal")
        // Set goal properties for removal - save
        goal.isRemoved = true
        goal.timeRemoved = Date()
        saveContext()
        
        // Remove goal from container and add to removedGoals
        removedGoals.append(goal)
        pastGoalContainer.removeAll(where: {$0.goal_UID == goal.goal_UID! })
    }
    
    // Undo delete goal - only use in .goalMode
    func undoDeleteGoal() {
        print("undoGoalDelete")
        
        if removedGoals.count != 0 {
            // sorting removed goals for most recent
            if removedGoals.count >= 2 {
//                goalDC.sortRemovedGoalsByTimeRemoved()
            }
            guard let mostRecentGoal = removedGoals.first else { return }
            // update goal properties
            mostRecentGoal.isRemoved = false
            mostRecentGoal.timeRemoved = nil
            // update tasks for goal properties
            
            taskDC.fetchTasksFor(goalUID: mostRecentGoal.goal_UID!)
            
            // add to past goal array and sort
            pastGoalContainer.append(mostRecentGoal)
            removedGoals.removeAll { (goal) -> Bool in
                goal.goal_UID! == mostRecentGoal.goal_UID!
            }
            sortPastGoalsByDate()
            // Save
            saveContext()
            taskDC.saveContext()
        }
        
    }
    
    
}

