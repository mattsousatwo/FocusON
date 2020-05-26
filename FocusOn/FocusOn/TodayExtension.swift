//
//  TodayExtension.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/11/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import UIKit
import Foundation

extension TodayVC {
    
    // Configure TodayVC
    func configureTodayVC() {
        // Assign Delegates
        todayTable.dataSource = self
        todayTable.delegate = self
        // fetch CoreData Elements
        goalDC.fetchGoals()
        todaysGoal = goalDC.goalContainer.first!
        taskDC.fetchTasks(with: todaysGoal.goal_UID!)
        // Set up view
        registerForKeyboardNotifications()
        updateTaskCountAndNotifications()
        addButtonIsHidden(true)
        // Prompt user to create tasks 
        if todaysGoal.name == "" {
            presentNewDayActionSheet()
        }
    }
    
    // updateTaskCount and reset notification timer
    func updateTaskCountAndNotifications() {
        updateCompletedTasksLabel()
        manageLocalNotifications()
    }
    
    // Display / update task count label
    func updateCompletedTasksLabel() {
        navigationItem.title = "Task Count: 0/4"
        var tempCount: Int16 = 0
        guard let totalTasks = todayTable.visibleCells as? [TaskCell] else { return }
        if totalTasks.count != 0 {
            for task in totalTasks {
                if task.taskMarker.isHighlighted == true {
                    tempCount+=1
                }
            }
            todaysGoal.completedCellCount = tempCount
            goalDC.saveContext()
            navigationItem.title = "Task Count: \(todaysGoal.completedCellCount)\\\(taskDC.currentTaskContainer.count + 1)"
            print("task count = \(totalTasks.count)")
        }

    }
    
    // alert controller to add a new task in todayVC
    func presentNewTaskAlertController() {
          let alertController = UIAlertController(title: "Add a new Task", message: nil, preferredStyle: .alert)
            
          alertController.addTextField(configurationHandler: {
              textfield in
              textfield.placeholder = "New Task"
          })
          
          let addTask = UIAlertAction(title: "Add Task", style: .default) { (action) in
              guard let alertText = alertController.textFields?.first?.text else { return }
              // MARK: Save Bonus Task
              self.taskDC.saveTask(name: alertText, withGoalID: self.todaysGoal.goal_UID!)
              print(alertText)
              self.updateTaskCountAndNotifications()
              self.todayTable.reloadData()
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action")
          }
              
          
          alertController.addAction(addTask)
          alertController.addAction(cancelAction)
          present(alertController, animated: true)
    }
    
    // Alert Controller to tell user to create three tasks
    func presentNewDayActionSheet() {
        let title = "It's a New Day!"
        let message = "Name a Goal for the day, and create three Tasks to complete that goal. Good Luck!"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Got it!", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    // Enable/Disable addTaskButton/functionality
    func addButtonIsHidden(_ isHidden: Bool) {
        switch isHidden {
        case true:
            addTaskButton.isEnabled = false
            addTaskButton.tintColor = UIColor.clear
        case false:
            addTaskButton.isEnabled = true
            addTaskButton.tintColor = UIColor.blue
        }
    }
    
    // Enable add button if three tasks are filled
    func checkRowsForCompletion() {
        guard let visibleCells = todayTable.visibleCells as? [TaskCell] else { return }
        let filteredCells = visibleCells.filter( { $0.textField.text != ""} )
        if visibleCells.count == filteredCells.count {
            print("filtered cells test works")
            addButtonIsHidden(false)
        } else {
            print("Cells are empty")
        }
    }
    
    // Check if all rows are checked, if so check off goal
    func checkMarkersInRowsForCompletion() {
        guard let visibleCells = todayTable.visibleCells as? [TaskCell] else { return }
        let checkedCells = visibleCells.filter( { $0.taskMarker.isHighlighted == true } )
        if checkedCells.count == visibleCells.count - 1 {
            let firstCell = todayTable.cellForRow(at: [0,0]) as! TaskCell
            firstCell.taskMarker.isHighlighted = true
            todaysGoal.isChecked = true
            goalDC.saveContext()
        }
    }
    
    // Editing Cell Did Finish - save task or goal
    func saveTextFrom(sender: UITextField?) {
        guard let textField = sender else { return }
        guard let index = todayTable.getIndexPath(of: textField) else { return }
        
        switch index.section {
        case 0: // Goal
            todaysGoal.name = textField.text!
            goalDC.saveContext()
            print(#function + " Goal Row")
        default: // Default
            if taskDC.currentTaskContainer.count != 0 {
                taskDC.currentTaskContainer[index.row].name = textField.text
                taskDC.saveContext()
                print(#function + " Task Row")
            }
        }
        // Check to see if visible textfields are all filled in - activate add button
        checkRowsForCompletion()
        // Check if all markers are checked
        checkMarkersInRowsForCompletion()
    }
    
    // TaskCell Delegate
    func taskMarkerWasPressed(_ marker: Bool, _ cell: TaskCell) {
        guard let visibleRows = todayTable.indexPathsForVisibleRows else { return }
        guard let firstCell = todayTable.cellForRow(at: [0,0]) as? TaskCell else { return }
        // Save marker selection
        switch cell {
        case firstCell:
            print("firstCell was pressed -------")
            todaysGoal.isChecked = marker
            // all task markers are complete
            for visibleRowIndex in visibleRows {
                guard let visibleCell = todayTable.cellForRow(at: visibleRowIndex) as? TaskCell else { return }
                visibleCell.taskMarker.isHighlighted = marker
                print("visibleCell = \(visibleRowIndex)")
                if visibleRowIndex.section > 0 {
                    let rowIndex = visibleRowIndex
                    let task = taskDC.currentTaskContainer[rowIndex.row]
                    task.isChecked = marker
                }
            }
            
            goalDC.saveContext()
            taskDC.saveContext()
        default:
            guard let x = todayTable.indexPath(for: cell) else { return }
            let task = taskDC.currentTaskContainer[x.row]
            task.isChecked = marker
            taskDC.saveContext()
        }
        
        // Update completed task count
        updateTaskCountAndNotifications()
        // Check if all task markers are complete
        checkMarkersInRowsForCompletion()
        
    }
    
    
    
    
} // TodayVC
