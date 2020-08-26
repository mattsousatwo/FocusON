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
    
    // DataControllers
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    // (All) Goals & Tasks
    var goals: [GoalData] = []
    var tasks: [TaskData] = []
    // Current Month
    var goalsFromCurrentMonth: [GoalData] = []
    var tasksFromCurrentMonth: [TaskData] = []
    // Current Week
    var goalsFromCurrentWeek: [GoalData] = []
    var tasksFromCurrentWeek: [TaskData] = []
    
    var average: String = ""
    var checkedGoalsCount: Double = 0
    var totalGoalCount: Double = 0
    var displayMode: GraphDisplayMode = .weekly
    
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
        // Number of task count + 1 (goal)
        return Double(array.count + 1)
    }
    
    // Get average of completed tasks
    func averageOfCompletion(goals: [GoalData], tasks: [TaskData]) -> String {
        var average: Double = 0
        var checkedCountForGoal: Double = 0
        var sumOfGoalsTasks: Double = 0
        // iterate through goals & tasks to get count
        for goal in goals {
            checkedCountForGoal += countOfCheckedTasksForGoal(with: goal, in: tasks)
            sumOfGoalsTasks += numberOfTasksFor(goal: goal.goal_UID!, in: tasks)
        }
        // Get average
        average = checkedCountForGoal / sumOfGoalsTasks
        print("Average = CheckedGoalsCount: \(checkedCountForGoal) / totalGoalCount: \(sumOfGoalsTasks)")
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
    
    
    // return average depending on display mode
    func getAverageForDisplayMode() -> String {
        var avg = ""
        switch displayMode {
        case .all:
            avg = averageOfCompletion(goals: goals, tasks: tasks)
        case .monthly:
            avg = averageOfCompletion(goals: goalsFromCurrentMonth, tasks: tasksFromCurrentMonth)
        case .weekly:
            avg = averageOfCompletion(goals: goalsFromCurrentWeek, tasks: tasksFromCurrentWeek)
        }
        print("avg: \(avg)")
        return avg
    }
    
    // load goals and tasks
    func fetchDataEntries() {
        // Load Goals
        goals = goalDC.fetchAllGoals()
        // Sort goals by date
        goals.sort { (goalA, goalB) -> Bool in
            goalA.dateCreated! < goalB.dateCreated!
        }
        
        tasks = taskDC.fetchAllTasks()
    }
    
    // Getting Goals by date - load all data to tasks and goals before calling
    
    // Current Week
    // Sort through goals depending on Date - Display last 7 days
    func getPastWeeksGoals() {
        for goal in goals {
            if goalDC.isDateFromCurrentWeek(goal.dateCreated) == true {
                goalsFromCurrentWeek.append(goal)
                goalsFromCurrentWeek.sort { (goalA, goalB) -> Bool in
                    goalA.dateCreated! > goalB.dateCreated!
                }
            }
            for task in tasks {
                if task.goal_UID == goal.goal_UID {
                    tasksFromCurrentWeek.append(task)
                }
            }
        }
        
    }

     // Current Month
     // Sort through goals depending on Date - Display Months goals
     func getCurrentMonthsGoals() {
         for goal in goals {
             if goalDC.isDateFromCurrentMonth(goal.dateCreated) == true {
                 goalsFromCurrentMonth.append(goal)
                goalsFromCurrentMonth.sort { (goalA, goalB) -> Bool in
                    goalA.dateCreated! > goalB.dateCreated!
                }
             }
             for task in tasks {
                 if task.goal_UID == goal.goal_UID {
                     tasksFromCurrentMonth.append(task)
                 }
             }

         }
     }
    
}

// Display Modes for Graphs
enum GraphDisplayMode: String {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case all = "All"
}
