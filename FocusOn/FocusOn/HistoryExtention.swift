//
//  HistoryExtention.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/11/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
enum DisplayMode: String {
    case goalMode = "Display: GoalMode\n", taskMode = "Display: TaskMode\n"
}

enum DeletedTaskMode {
    case goal, task, deleteAll
}


import UIKit

extension HistoryVC {
    
    // Configure historyView
    func configureHistoryVC() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        goalDC.fetchGoals()
        backButtonIsHidden(true)
    }
    
    
    // Enable/Disable backBarButton & functionality of button
    func backButtonIsHidden(_ isHidden: Bool) {
        if isHidden == true {
            displayMode = .goalMode
            backBarButton.isEnabled = false
            backBarButton.tintColor = UIColor.clear
            historyTableView.reloadData()
        } else { // isHidden == false
            backBarButton.isEnabled = true
            backBarButton.tintColor = UIColor.blue
        }
        
    }
    
    // adding button to swap display modes
    func addMenuGesture(to cell: TaskCell, in view: UIViewController) {
        let gesture = UITapGestureRecognizer(target: view, action: #selector(taskModeButtonWasPressed))
        cell.menuButton.addGestureRecognizer(gesture)
    }
    
    // swap display modes when menu button was pressed
    @objc func taskModeButtonWasPressed() {
        print(#function)
        displayMode = .taskMode
        backButtonIsHidden(false)
        selectedGoal = goalDC.fetchGoal(withUID: selectedGoalID)
        taskDC.fetchTasksFor(goalUID: selectedGoalID)
        historyTableView.reloadData()
        // MARK: if displayMode == .taskMode { segue to detailView } 
    }
    
    // Delete specific goal - from pastGoalContainer
    func delete(_ goal: GoalData, at index: IndexPath, displayMode: DisplayMode) {
        lastDeletedGoal = goal
        lastDeletedGoalIndex = index
        goalDC.delete(goal: goal, at: index, in: historyTableView)
        historyTableView.reloadData()
    }
    
    // Delete specific task
    func delete(_ task: TaskData, at index: IndexPath) {
        lastDeletedTask = task
        lastDeletedTaskIndex = index
        taskDC.deleteTaskFromHistory(at: index, in: historyTableView)
        historyTableView.reloadData()
    }
    
    // Check to see if any tasks are being stored for Undo func
    func checkDeleteMode() -> DeletedTaskMode? {
        if lastDeletedTask != nil { // Undo Task
            return .task
        } else if lastDeletedGoal != nil { // Undo Goal
            return .goal
        } else if deleteAllGoal != nil { // Undo All
            return .deleteAll
        }
        return nil
    }
    
    func clearDeletedCache(_ excluding: DeletedTaskMode? = nil) {
        guard let excluding = excluding else {
            lastDeletedGoal = nil
            lastDeletedGoalIndex = nil
            lastDeletedTask = nil
            lastDeletedTaskIndex = nil
            deleteAllGoal = nil
            deleteAllGoalIndex = nil
            deleteAllGoalPosition = nil
            deleteAllTasks = nil
            deleteAllTasksIndex = nil
            return
        }
        
        switch excluding {
        case .deleteAll:
            lastDeletedGoal = nil
            lastDeletedGoalIndex = nil
            lastDeletedTask = nil
            lastDeletedTaskIndex = nil
        case .goal:
            lastDeletedTask = nil
            lastDeletedTaskIndex = nil
            deleteAllGoal = nil
            deleteAllGoalIndex = nil
            deleteAllTasks = nil
            deleteAllTasksIndex = nil
        case .task:
            lastDeletedGoal = nil
            lastDeletedGoalIndex = nil
            deleteAllGoal = nil
            deleteAllGoalIndex = nil
            deleteAllTasks = nil
            deleteAllTasksIndex = nil
        }
    }
    
    
    // Delete All Warning
    func presentDeleteAllWarrning() {
        let title = "Warrning: Deleting All Tasks"
        let message = "Warrning: Pressing delete will remove the goal and all tasks that are saved with it. Would you like to remove these files?"
        // Initialize AlertController
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
        let customAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in print("Launch Custom Action")
            
            self.removeGoalAndTasks()
            self.displayMode = .goalMode
            self.backButtonIsHidden(true)
            self.historyTableView.reloadData()
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action")
        }
            
        // Add Action to Controller
        alertController.addAction(customAction)
            
        alertController.addAction(cancelAction)
            
        // Present View Controller
        present(alertController, animated: true)
        
    }
    
    // Delete Selected Goal and all saved tasks with the goals UID
    func removeGoalAndTasks() {
        clearDeletedCache()
        guard let selectedGoal = selectedGoal else { return }
        guard let goalPosition = goalDC.pastGoalContainer.firstIndex(where: {$0.goal_UID == selectedGoal.goal_UID!} ) else { return }
        // store to be deleted files
        deleteAllGoal = goalDC.pastGoalContainer.first(where: {$0.goal_UID == selectedGoal.goal_UID} )
        deleteAllGoalPosition = goalPosition
        deleteAllTasks = taskDC.selectedTaskContainer
        deleteAllTasksIndex = historyTableView.indexPathsForVisibleRows!
        deleteAllTasksIndex?.removeFirst()
        
        // remove files
        goalDC.pastGoalContainer.removeAll(where: {$0.goal_UID == selectedGoal.goal_UID!} )
        taskDC.selectedTaskContainer.removeAll()
        goalDC.saveContext()
        taskDC.saveContext()
        
        // Go back to goalMode
        backButtonIsHidden(true)
        selectedGoalID = ""
    }
    
    
}
