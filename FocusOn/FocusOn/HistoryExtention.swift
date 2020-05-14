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
        newTaskButtonIsHidden(true)
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
    
    // Enable/Disable newTaskButton & functionality of button
    func newTaskButtonIsHidden(_ isHidden: Bool) {
        if isHidden == true {
            newTaskButton.isEnabled = false
            newTaskButton.tintColor = UIColor.clear
        } else { // isHidden == false
            newTaskButton.isEnabled = true
            newTaskButton.tintColor = UIColor.blue
        }
    }
    
    // Presnet Alert Controller and save task
    func presentNewTaskMessage() {
        let alertController = UIAlertController(title: "Add a new Task", message: nil, preferredStyle: .alert)
          
        alertController.addTextField(configurationHandler: {
            textfield in
            textfield.placeholder = "New Task"
        })
        
        let addTask = UIAlertAction(title: "Add Task", style: .default) { (action) in
            guard let alertText = alertController.textFields?.first?.text else { return }
            // MARK: Save Bonus Task
            self.taskDC.saveTask(name: alertText, withGoalID: self.selectedGoalID)
            print(alertText)
            self.taskDC.fetchTasksFor(goalUID: self.selectedGoalID)
            self.historyTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action")
        }
            
        
        alertController.addAction(addTask)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // adding button to swap display modes
    func addMenuGesture(to cell: TaskCell, in view: UIViewController) {
        let gesture = UITapGestureRecognizer(target: view, action: #selector(taskModeButtonWasPressed))
        cell.menuButton.addGestureRecognizer(gesture)
    }
    
    // swap display modes when menu button was pressed
    @objc func taskModeButtonWasPressed() {
        print(#function)
        // MARK: if displayMode == .taskMode { segue to detailView }
        
        switch displayMode {
        case .goalMode:
            print(".goalMode went through")
            displayMode = .taskMode
            backButtonIsHidden(false)
            newTaskButtonIsHidden(false)
            selectedGoal = goalDC.fetchGoal(withUID: selectedGoalID)
            taskDC.fetchTasksFor(goalUID: selectedGoalID)
            historyTableView.reloadData()
        case .taskMode:
            // setup Segue
            print(".taskMode went through")
            // SETUP PREPARE FOR SEGUE
            // send over searchType & searchUID
            if historyTableView.indexPathForSelectedRow == [0,0] {
                guard let selectedGoal = selectedGoal else { return }
                print("Test 1 - taskModeButton")
                selectedGoalID = selectedGoal.goal_UID!
                dataType = .goal
            } else {
                guard let selectedIndex = historyTableView.indexPathForSelectedRow else { return }
                print("Test 2 - taskModeButton")
                if taskDC.selectedTaskContainer.count != 0 {
                    selectedTaskID = taskDC.selectedTaskContainer[selectedIndex.row].task_UID!
                    dataType = .task
                }
            }
            performSegue(withIdentifier: "HistoryToDetail", sender: nil)
        }
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
    
    // Func to remove saved deleted tasks - Maybe can remove excluding clause
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
        newTaskButtonIsHidden(true)
        selectedGoalID = ""
    }
    
    
}
