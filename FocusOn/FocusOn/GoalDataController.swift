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
        print("goalContainer.count: \(goalContainer.count)")
        
        // if there is a goal in goalContainer & first goal is from today
        if goalContainer.count != 0 &&
            compareDays(from: (goalContainer.first?.dateCreated)! ) == false {
            print("goalContainer.count != 0 && compareDays(from: ) == false \n")
            for data in goalContainer {
                if compareDays(from: (data.dateCreated)!) == false  {
                    // if data.dateCreated != today, add & remove goal
                    // MARK: compareDays == true && uncomment removeAll() - for createTestData() 
                    pastGoalContainer.append(data)
                    goalContainer.removeAll(where: { $0.goal_UID! == data.goal_UID! })
                    saveGoal(goal: Goal() )
                }
            }
            print("\n+++++ goalContainer.count = \(goalContainer.count)")
            print("+++++ pastGoalContainer.count = \(pastGoalContainer.count)\n")
        } else if goalContainer.count == 0 || compareDays(from: (goalContainer.first?.dateCreated)! ) == true { // if goalContainer isEmpty create a new GoalData entity
            print("goalContainer.count == 0 && compareDays(from: ) == true \n")
            saveGoal(goal: Goal())
        }
    }
       
    // MARK: Delete
    func delete(goal: GoalData, at indexPath: IndexPath?, in table: UITableView) {
        guard let indexPath = indexPath else { return }
        table.beginUpdates()
        pastGoalContainer.removeAll(where: { $0.goal_UID == goal.goal_UID!})
        table.deleteRows(at: [indexPath], with: .automatic)
        table.endUpdates()
        saveContext()
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
    
    // MARK: Date Caption
    
    
    
}
