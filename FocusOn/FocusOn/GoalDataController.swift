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
    // should i make a file for each data class?
    var entityName = "GoalData"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    var goalContainer: [GoalData] = []
    var currentGoal = GoalData()
    var pastGoalContainer: [GoalData] = []
    
    var today: Date {
        return startOfTheDay()
    }

    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    // MARK: Save
    func saveGoal(goal: Goal, title: String = "" ) {
        print(#function)
         
        // maybe some logic to update goal
        
        let xGoal = GoalData(context: context)
        
        xGoal.dateCreated = Date()
        xGoal.goal_UID = goal.UID
        if title == "" {
            xGoal.name = goal.title
        } else {
            xGoal.name = title
        }
        
        goalContainer.append(xGoal)
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
    
    // MARK: Create
    func create() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    func createTestGoals() {
        for x in 1...5 {
            saveGoal(goal: Goal(), title: "Test\(x)") 
        }
    }
    
    
    // MARK: Update
    func update(context: NSManagedObject?, withGoal goal: Goal) {
        if let oldGoal = context {
            oldGoal.setValue(goal, forKey: "Goal")
        }
    }
    
    
    func update(goal: Goal) {
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        // need to find a way to match the days goal
        // here we can only find the goal once because the next time goal.UID is initalized it will be a new UID, thus serching for nothing
        // maybe adjust goal.init??? || use the timestamp on the goal to load the goal into view and then make adjustments to that gaol 
        
        request.predicate = NSPredicate(format: "goal_UID = %@", goal.UID)
        do {
            let selectedGoal = try context.fetch(request)
            if selectedGoal.count != 0 {
                let x = selectedGoal.first
                x?.name = goal.title
                saveContext()
            }
        } catch let error as NSError {
            print("Could not update GoalData: \(error), \(error.userInfo)")
        }
        print(goalContainer.first?.name ?? "default")
    }

    
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
    
    func fetchPastGoal() {
        
    }
    
    func fetchTodaysGoal() -> GoalData? {
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        do {
            let fetch = try context.fetch(request)
            if fetch.count != 0 {
                let goal = fetch.last!
                if Calendar.current.isDateInToday(goal.dateCreated!) == true {
                    return goal
                } else {
                    // create goal 
                    saveGoal(goal: Goal())
                    return fetch.last!
                }
                
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    
    // MARK: Fetch Data
    // Fetch all goals, if goal is in the past append goal into pastGoalContainer
    func fetchGoals() {
        print(#function)
        let request: NSFetchRequest<GoalData> = GoalData.fetchRequest()
        do {
            goalContainer = try context.fetch(request) // request all goals
        } catch let error as NSError {
            print("Could not fetch GoalData: \(error), \(error.userInfo)")
        }
//        print("goalContainer.count: \(goalContainer.count)")
        
        // if there is a goal in goalContainer & first goal is from today
        if goalContainer.count != 0 &&
            compareDays(from: (goalContainer.first?.dateCreated)! ) == false {
//            print("goalContainer.count != 0 && compareDays(from: ) == false \n")
            if pastGoalContainer.count != 0 {
                pastGoalContainer.removeAll()
            }
            for data in goalContainer {
                if compareDays(from: (data.dateCreated)!) == false  {
                    // if data.dateCreated != today, add & remove goal
                    // MARK: compareDays == true && uncomment removeAll() - for createTestData()
//                    print("Test 100 - count BEFORE : \(goalContainer.count)")
                    pastGoalContainer.append(data)
                    goalContainer.removeAll(where: { $0.goal_UID! == data.goal_UID! })
                    saveGoal(goal: Goal() )
//                    print("Test 100 - count AFTER : \(goalContainer.count)")
                }
            }

//            print("\n+++++ goalContainer.count = \(goalContainer.count)")
//            print("+++++ pastGoalContainer.count = \(pastGoalContainer.count)\n")
        } else if goalContainer.count == 0 || compareDays(from: (goalContainer.first?.dateCreated)! ) == true { // if goalContainer isEmpty create a new GoalData entity
//            print("goalContainer.count == 0 && compareDays(from: ) == true \n")
            saveGoal(goal: Goal())
        }
    }
       
    // MARK: Delete
    // Used in HistoryVC to delete a goal 
    func delete(goal: GoalData, at indexPath: IndexPath, in table: UITableView) {
        
        print("Test 102 " + "goal: \(goal.goal_UID!), at: [\(indexPath)], count: \(pastGoalContainer.count)")
        table.beginUpdates()
            
        pastGoalContainer.removeAll(where: { $0.goal_UID == goal.goal_UID!})
            
        deleteGoalsWith(UIDs: [goal.goal_UID!] )
            
        table.deleteRows(at: [indexPath], with: .automatic)
            
        table.deleteSections([indexPath.section], with: .automatic)
            
        table.endUpdates()
            
        saveContext()
        
        print("Test 102 " + "goal: \(goal.goal_UID!), at: [\(indexPath)], count: \(pastGoalContainer.count)")
        
        
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
    
    
    
    /*
    func getTodaysGoal() -> GoalData {
        
        if goalContainer.count >= 1 {
            if compareDays(from: goalContainer.first!.dateCreated!) == true {
                return goalContainer.last!
            }
        }
        let x: GoalData
      
    }
    */
    
    // New Fetch Goals method - May 27
    func getGoals() {
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
            // MARK: Delete goals go here ---------
            parseGoals()
        case false:
            printOne(#function + "container.count != 0: FALSE")
            // Goal Container is empty
            // Check if currentGoal is in pastGoalContainer
            compareCurrentGoalToPastGoals()
        }
        printOneOutcome()
        printOne(#function + " --- end")
    }
    
    // Seperate CurrentGoals VS PastGoals
    func parseGoals() {
        printOne(#function)
        // Check if goalContainer is nil
        switch goalContainer.count != 0 {
        case true:
            // Goal Container has goals
            // clear
            // clearDoubles()
            sortThroughDates()
        case false:
            // is empty
            createNewCurrentGoal()
        }
    }
    
    // Get all past goal UIDs - used for deletion
    func pastGoalUIDs() -> [String]? {
        var goalUIDs: [String]?
        if pastGoalContainer.count != 0 {
            goalUIDs = pastGoalContainer.map({ (goal) -> String in
                return goal.goal_UID!
            })
        }
        return goalUIDs
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
    
    
    // Delete goal if in goalContainer and pastGoalContainer and != currentGoal
    func clearDoubles() {
        printOne(#function + " --- start")
        printOne("goalContainer.count = \(goalContainer.count) [ A ]")
        printOne("pastGoalContainer.count = \(pastGoalContainer.count) [ A ]")
        for goalC in goalContainer {
            for goalP in pastGoalContainer {
                if goalC == goalP  &&  currentGoal != goalC {
                    deleteGoalsWith(UIDs: [goalC.goal_UID!])
                }
            }
        }
        printOne("goalContainer.count = \(goalContainer.count) [ A ]")
        printOne("pastGoalContainer.count = \(pastGoalContainer.count) [ A ]")
        printOne(#function + " --- end")
    }
    
    // Sort goals by their dates into pastGoalContainer or if from today set as currentGoal
    func sortThroughDates() {
        printOne(#function + " --- start")
        for goal in goalContainer {
            // if goal is not from today
            if isDateFromToday(goal.dateCreated) == false {
                printOne("isDateFromToday(goal.dateCreated) == false { add to goal && remove }")
                // move to past container
                pastGoalContainer.append(goal)
                printOne("pastGoalContainer.count = \(pastGoalContainer.count) [  B ]")
                // remove goal from goal container
                goalContainer.removeAll(where: { $0.goal_UID == goal.goal_UID! })
                printOne("goalUID == \(goal.goal_UID!)")
                printOne("goalContainer.count = \(goalContainer.count) [  B ]")
                if goalContainer.count == 0 {
                    createNewCurrentGoal()
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
    
    // Create new goal and set it as current goal
    func createNewCurrentGoal() {
        printOne(#function + " --- start")
        printOne("goalContainer.count = \(goalContainer.count) [   C ]")
        saveGoal(goal: Goal())
        currentGoal = goalContainer.first!
        printOne("goalContainer.count = \(goalContainer.count) [    D ]")
        // Maybe should remove goal after adding
        printOne(#function + " --- end")
    }
    
}
