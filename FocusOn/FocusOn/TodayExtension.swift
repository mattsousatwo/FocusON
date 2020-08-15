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
    
    func testIfLastThreeMonthsGraphWorks() {
        let d = DataController()
        
        let january = d.createDate(month: 1, day: 1, year: 2020)
        let feburary = d.createDate(month: 2, day: 1, year: 2020)
        let march = d.createDate(month: 3, day: 1, year: 2020)
        let april = d.createDate(month: 4, day: 1, year: 2020)
        let may = d.createDate(month: 5, day: 1, year: 2020)
        let june = d.createDate(month: 6, day: 1, year: 2020)
        let july = d.createDate(month: 7, day: 1, year: 2020)
        
        let goals = [january, feburary, march, april, may, june, july]
        var threeLastMonths: [Date] = []
        var notWithinLastThreeMonths: [Date] = []
        
        for goal in goals {
            if d.isDateFromLastThreeMonths(goal) == true {
                threeLastMonths.append(goal)
            } else {
                notWithinLastThreeMonths.append(goal)
            }
        }
        
        if threeLastMonths.count == 3 {
            print("lastThreeMonths - threeLastMonths.count = \(threeLastMonths.count)")
            print("lastThreeMonths - notWithinLastThreeMonths.count = \(notWithinLastThreeMonths.count)")
            
        } else {
            print("lastThreeMonths - threeLastMonths.count = \(threeLastMonths.count)")
            print("lastThreeMonths - notWithinLastThreeMonths.count = \(notWithinLastThreeMonths.count)")
            
        }
        
    }
    
    // Delete all Goals Tasks
    func deleteGoalsAndTasks(_ bool: Bool = true) {
        switch bool {
        case true:
            print(#function + " true")
            goalDC.deleteAll()
            taskDC.deleteAllTasks()
        default:
            print(#function + " false")
        }
    }
    
    // Configure TodayVC
    func configureTodayVC() {

//        deleteGoalsAndTasks(false)
        
//        goalDC.createTestGoals(int: 6, month: 8)
        
        // Assign Delegates
        todayTable.dataSource = self
        todayTable.delegate = self
        
        // fetch CoreData Elements
        goalDC.getGoals()
        
        // Set main goal for the day
        todaysGoal = goalDC.currentGoal
        
        // get all tasks for goal
        taskDC.fetchTasks(with: todaysGoal.goal_UID!)
        
        // Set up view
        registerForKeyboardNotifications()
        updateTaskCountAndNotifications()
        
        // hide add button
        addButtonIsHidden(true)
        // if all cells have text in thier textfield - enable add new task button
        checkIfCellsAreFull()
        // Prompt user to create tasks 
        if todaysGoal.name == "" {
            presentNewDayActionSheet()
        }
    }
    
    // configureView After View Appears
    func configureViewDidAppear() {
        // Reload tasks if changes
        for goal in goalDC.goalContainer {
            if goal.hasChanges == true {
                goalDC.getGoals()
            }
        }
        
        // if current goal changed (if new day) - load new task
         if todaysGoal.goal_UID! != goalDC.currentGoal.goal_UID! {
            todaysGoal = goalDC.currentGoal
        }
        
        // get tasks if changes
        for task in taskDC.currentTaskContainer {
            if task.hasChanges == true {
                taskDC.fetchTasks(with: todaysGoal.goal_UID!)
            }
        }
        
        todayTable.reloadData()
        updateTaskCountAndNotifications()
        
            // Not sure what it does - sets all task markers depending on goal marker
        todayTable.checkGoalToUpdateTaskCells()
        
        print(#function)
        
        print("\n taskDC.selected Count = \(self.taskDC.selectedTaskContainer.count) " + "taskDC.current Count = \(self.taskDC.currentTaskContainer.count) ")
        
        todayTable.clearMenuButtons()
    }
    
    // updateTaskCount and reset notification timer
    func updateTaskCountAndNotifications() {
        updateCompletedTasksLabel()
        manageLocalNotifications()
    }
      
    // Display / update task count label
    func updateCompletedTasksLabel() {
        navigationItem.title = "Task Count: 0/4"
        guard let totalTasks = todayTable.visibleCells as? [TaskCell] else { return }
        if totalTasks.count != 0 {
            
            let highlightedTaskCells = totalTasks.filter( { $0.taskMarker.isHighlighted == true })
            todaysGoal.completedCellCount = Int16(highlightedTaskCells.count)
            goalDC.saveContext()
            navigationItem.title = "Task Count: \(highlightedTaskCells.count)\\\(taskDC.currentTaskContainer.count + 1)"
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
            
            // test if string has characters
            if alertText != "" {
                self.taskDC.saveTask(name: alertText, withGoalID: self.todaysGoal.goal_UID!)
                print(alertText)
                self.updateTaskCountAndNotifications()
                self.todayTable.reloadData()
                // uncheck goal if checked off and goal was added kl
                self.checkMarkersInRowsForCompletion()
            }
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action") }
              
          
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
    func checkIfCellsAreFull() {
        guard let visibleCells = todayTable.visibleCells as? [TaskCell] else { return }
        let filteredCells = visibleCells.filter( { $0.textField.text != ""} )
        if visibleCells.count == filteredCells.count {
            print("filtered cells test works")
            addButtonIsHidden(false)
        } else {
            print("Cells are empty")
        }
    }
    
    // MARK: SHOULD REFACTOR
    // Check if all rows are checked, if so check off goal
    func checkMarkersInRowsForCompletion() {
        // total cells
        guard let totalCells = todayTable.visibleCells as? [TaskCell] else { return }
        // Count == number of cells to complete goal
        let countToCompleteGoal = totalCells.count - 1
        let lessThanCompletion = countToCompleteGoal - 1
        
       
        // cells that are checked off
        let checkedCellsInView = totalCells.filter( { $0.taskMarker.isHighlighted == true } )
        // Append cells if in section 1
        var checkedCells = [TaskCell]()
        for cell in checkedCellsInView {
            if todayTable.indexPath(for: cell)?.section == 1 {
                checkedCells.append(cell)
            }
        }

        print("checkedGoals = \(checkedCells.count) : \(countToCompleteGoal) ( \(lessThanCompletion) )")
        print("checkedGoals -- todaysGoal.isChecked = \(todaysGoal.isChecked)")
        
        
        // first cell
        let firstCell = todayTable.cellForRow(at: [0,0]) as! TaskCell
        
        // If checkedCells are == totalCells
        if checkedCells.count == countToCompleteGoal {
            
            firstCell.taskMarker.isHighlighted = true
            todaysGoal.isChecked = true
            goalDC.saveContext()
            // use todays goal to access GoalData
            animation.playCompletionAnimationIn(view: view, of: self, withType: .today, for: todaysGoal, in: firstCell)
            // If checkedCells are less than count needed to complete goal
        } else if checkedCells.count == lessThanCompletion &&
        firstCell.taskMarker.isHighlighted == true {
            
            
            todaysGoal.isChecked = false
            firstCell.taskMarker.isHighlighted = false
                                
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
        default: // Default -- couldt remove saving tasks text as it is not used
            if taskDC.currentTaskContainer.count != 0 {
                taskDC.currentTaskContainer[index.row].name = textField.text
                taskDC.saveContext()
                print(#function + " Task Row")
            }
        }
        // Enable add button if three tasks are filled
        checkIfCellsAreFull()
    }
    
    // TaskCell Delegate
    func taskMarkerWasPressed(_ marker: Bool, _ cell: TaskCell) {
        print("Animation - Marker was pressed")
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
            guard let index = todayTable.indexPath(for: cell) else { return }
            let task = taskDC.currentTaskContainer[index.row]
            
            switch marker {
            case true:
                // If goal is not complete, play check task animation
                if todayTable.isGoalComplete() == false {
                    animation.playTaskAnimation(in: view, of: self, withType: .today, for: task, in: cell, ofStyle: .checkedTaskMessage)
                } // else checkMarkersInRowForCompletion will display animation
            case false:
                animation.playTaskAnimation(in: view, of: self, withType: .today, for: task, in: cell, ofStyle: .unCheckedTaskMessage)
            }
            
        }
        
        
        // Check if all task markers are complete
        checkMarkersInRowsForCompletion()

        // Update completed task count
        updateTaskCountAndNotifications()
        
    }
    
} // TodayVC
