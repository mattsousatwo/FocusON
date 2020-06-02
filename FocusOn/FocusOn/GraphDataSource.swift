//
//  GraphDataSource.swift
//  FocusOn
//
//  Created by Matthew Sousa on 6/1/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import Charts

class GraphDataSource {
    
    var average: String = ""
    var checkedGoalsCount: Double = 0
    var totalGoalCount: Double = 0
    var displayMode: GraphDisplayMode = .weekly
    
    // MARK: Multiple Entries are created at index if task is checked causeing there to be multiple labels for the count
    /// maybe multiple entries are created when a goal is checked off??
    /// is this just a feature of Charts?
    // Return count of checked tasks with matching goalUID
    func countOfCheckedTasksForGoal(with goal: GoalData, in taskContainer: [TaskData]) -> Double {
        var checkedTasks: [TaskData] = []
        var checkedGoals: [GoalData] = []
        
        if goal.isChecked == true {
            checkedGoals.append(goal)
        }
        for task in taskContainer {
            if task.goal_UID == goal.goal_UID && task.isChecked == true {
                checkedTasks.append(task)
            }
        }
        
        let total = Double(checkedTasks.count + checkedGoals.count)
        return total
    }
    
    // Return number of tasks for goal
    func numberOfTasksFor(goal: String, in taskContainer: [TaskData]) -> Double {
        var array: [TaskData] = []
        for task in taskContainer {
            if task.goal_UID == goal {
                array.append(task)
            }
        }
        return Double(array.count)
    }
    
    // Get average of completed tasks
    func averageOfCompletion(goals: [GoalData], tasks: [TaskData]) -> String {
        var average: Double = 0
        var checkedGoalsCount: Double = 0
        var totalGoalCount: Double = 0
        // iterate through goals & tasks to get count
        for goal in goals {
            checkedGoalsCount += countOfCheckedTasksForGoal(with: goal, in: tasks)
            totalGoalCount += numberOfTasksFor(goal: goal.goal_UID!, in: tasks)
        }
        // Get average
        average = checkedGoalsCount / totalGoalCount
        print("Average: \(average)")
        // Multiply by 100
        var multiple = average * 100
        // Round to remove extra digits
        multiple.round(.toNearestOrAwayFromZero)
        print("Multiplied: \(multiple)")
        // Set Double as String
        let string = "\(multiple)"
        // Check if == 100.0 or less than, drop decimal
        var revisedString = ""
        switch multiple {
        case 100.0:
            revisedString = "100"
        default:
            revisedString = String(string.dropLast(2))
        }
        // add %
        let finalString = revisedString + "%"
        print("Final: \(finalString)")
        return finalString
    }
    
    
    
    // sort goals for goals created in current Month - Display Goals in month
//    func getCurrentMonthsGoals() {
//
//    }
    
}

// Display Modes for Graphs
enum GraphDisplayMode: String {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case all = "All"
}
