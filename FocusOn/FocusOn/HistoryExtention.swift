//
//  HistoryExtention.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/11/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
  
import UIKit

extension HistoryVC {
    
    // Configure historyView
    func configureHistoryVC() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        goalDC.getGoals()
//        goalDC.fetchGoals()
        backButtonIsHidden(true)
        newTaskButtonIsHidden(true)
    }
    
    // Reload and clear search tags
    func configureViewDidAppear() {
        historyTableView.reloadData()
        historyTableView.clearMenuButtons()
        selectedGoalID = ""
        selectedTaskID = ""        
    }
    
    // TaskCellDelegate
    func updateMarker(for cell: TaskCell) {
        
        guard let visibleRows = historyTableView.indexPathsForVisibleRows else { return }
        
        switch displayMode {
        case .goalMode:
            for index in visibleRows {
                let goal = goalDC.pastGoalContainer[index.row]
                guard let markerSelection = taskColors(rawValue: goal.markerColor) else { return }
                cell.taskMarker.changeImageSet(to: markerSelection)
                cell.taskMarker.isHighlighted = goal.isChecked
                
            }
        case .taskMode:
            for index in visibleRows {
                switch index.section {
                case 0:
                    // Goal
                    guard let goal = selectedGoal else { return }
                    guard let markerSelection = taskColors(rawValue: goal.markerColor) else { return }
                    cell.taskMarker.changeImageSet(to: markerSelection)
                    cell.taskMarker.isHighlighted = goal.isChecked
                default:
                    // Task
                    let task = taskDC.selectedTaskContainer[index.row]
                    guard let markerSelection = taskColors(rawValue: task.markerColor) else { return }
                    cell.taskMarker.changeImageSet(to: markerSelection)
                    cell.taskMarker.isHighlighted = task.isChecked
                    
                }
            }
        }
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
            self.checkMarkersInRowsForCompletion()
            self.updateCompletedTasksLabelCount()
            print("BEFORE \n taskDC.selected Count = \(self.taskDC.selectedTaskContainer.count) " + "taskDC.current Count = \(self.taskDC.currentTaskContainer.count) ")
            
            
            print(" AFTER \n taskDC.selected Count = \(self.taskDC.selectedTaskContainer.count) " + "taskDC.current Count = \(self.taskDC.currentTaskContainer.count) ")
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
        guard let selectedIndex = historyTableView.indexPathForSelectedRow else { return }
        guard let selectedRow = historyTableView.cellForRow(at: selectedIndex) as? TaskCell else { return }
        switch displayMode {
        case .goalMode:
            print(".goalMode went through")
            displayMode = .taskMode
            backButtonIsHidden(false)
            newTaskButtonIsHidden(false)
            selectedGoal = goalDC.fetchGoal(withUID: selectedGoalID)
            taskDC.fetchTasksFor(goalUID: selectedGoalID)
            print("pastTaskContainer ---- selectedGoalID = \(selectedGoalID)")
            print("pastTaskContainer ---- taskDC.selectedTaskContainer.count = \(taskDC.selectedTaskContainer.count)")
            historyTableView.reloadData()
            selectedRow.menuButton.isHidden = true
            historyTableView.deselectRow(at: selectedIndex, animated: false)
            updateCompletedTasksLabelCount()
        case .taskMode:
            // setup Segue
            print(".taskMode went through")
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
        let newGoalID = goalDC.genID()
        // fetch goals for task
        taskDC.fetchTasksFor(goalUID: goal.goal_UID!)

        goal.goal_UID = newGoalID
        goalDC.saveContext()
        
        lastDeletedGoal = goal
        lastDeletedGoalIndex = index
        goalDC.delete(goal: goal, at: index, in: historyTableView)
        
        // add tasks to container
        deleteAllTasks = taskDC.selectedTaskContainer

        
        // Change to be deleted tasks IDs to allow the undo tasks to avoid deletion
        for task in taskDC.selectedTaskContainer {
            task.goal_UID = newGoalID
        }
        taskDC.saveContext()
        
        // delete tasks
        taskDC.selectedTaskContainer.removeAll()
//        taskDC.deleteAllTasks(with: goal.goal_UID!)
        taskDC.deleteAllTasks(with: newGoalID)
        
        taskDC.saveContext()
        clearDeletedCache(.goal)
        historyTableView.reloadData()
    }
    
    // Delete specific task
    func delete(_ task: TaskData, at index: IndexPath) {
        lastDeletedTask = task
        lastDeletedTaskIndex = index
        taskDC.deleteTaskFromHistory(at: index, in: historyTableView)
        clearDeletedCache(.task)
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
    
    // if delete mode is not equal to the type of deleted task we are bringing back the app will crash, so we need to ensure that when a task is being brought back, it is in task display mode
    func isUndoDeletionModeCorrect() -> Bool {
        
        func undoPrintStatement(_ input: String) {
            print("undoCheck :: " + input)
        }
        guard let lastDeletedType = checkDeleteMode() else { return false }
        
        undoPrintStatement(" INITAL - last deleted type = \(lastDeletedType), displayMode = \(displayMode)")
        
        switch lastDeletedType {
        case .deleteAll:
            // can only undo if goalMode
            if displayMode == .taskMode {
                undoPrintStatement("DeleteAll: displayMode = .taskMode -> FALSE")
                return false
            } else if displayMode == .goalMode {
                undoPrintStatement("DeleteAll: displayMode = .goalMode -> TRUE")
                return true
            }
            undoPrintStatement("DeleteAll: FAIL THROUGH")
            return false
        case .goal:
            // can only undo if in goalMode
            if displayMode == .taskMode {
                undoPrintStatement("goal: displayMode = .taskMode -> FALSE")
                return false
            } else if displayMode == .goalMode {
                undoPrintStatement("goal: displayMode = .goalMode -> TRUE")
                return true
            }
            undoPrintStatement("goal: FAIL THROUGH")
            return false
        case .task:
            guard let lastDeletedID = lastDeletedTask?.goal_UID else { return false }
            // can only undo if in taskMode and goalID matches
            if displayMode == .goalMode {
                undoPrintStatement("task: displayMode = .taskMode -> FALSE")
                return false
            } else if displayMode == .taskMode {
                if selectedGoalID == lastDeletedID {
                    undoPrintStatement("task: displayMode = .taskMode, sgID - \(selectedGoalID) : ldID - \(lastDeletedID) -> TRUE")
                    return true
                }
                undoPrintStatement("task: displayMode = .taskMode -> FALSE")
                return false
            }
            undoPrintStatement("task: FAIL THROUGH")
            return false
        }
        
        return true
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
            
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in print("Launch Custom Action")
            
            self.removeGoalAndTasks()
            self.displayMode = .goalMode
            self.backButtonIsHidden(true)
            self.navigationItem.title = "History"
            self.historyTableView.reloadData()
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action")
        }
            
        // Add Action to Controller
        alertController.addAction(deleteAction)
            
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
        // Remove goals index
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
    
    // Editing cell ended - save task or goal - will only be run in .taskMode
    func saveTextFrom(sender: UITextField?) {
        guard let textField = sender else { return }
        guard let index = historyTableView.getIndexPath(of: textField) else { return }
        
        switch index.section {
        case 0: // Goal
            if textField.text != nil {
                selectedGoal?.name = textField.text
                goalDC.saveContext()
                print(#function + " Goal Row")
            }
        default: // Task
            if taskDC.selectedTaskContainer.count != 0 {
                taskDC.selectedTaskContainer[index.row].name = textField.text
                taskDC.saveContext()
                print(#function + " Task Row")
            }
        }

    }
  
    
    // Func to print test statments 
    func printMarkerSelection(for goal: GoalData? = nil, for task: TaskData? = nil) {
        if let goal = goal {
            print("printMarkerSelection: goal: \(goal.isChecked)")
        } else if let task = task {
            print("printMarkerSelection: task: \(task.isChecked)")
        }
    print("printMarkerSelection: --------" + "\n")
    }
    
    
    // Check row markers and check off goal if tasks are complete
    func checkMarkersInRowsForCompletion() {
        print(#function)
        // TotalCells
        guard let totalCells = historyTableView.visibleCells as? [TaskCell] else { return }
        // number of cells to complete goal
        let countToCheckOffGoal = totalCells.count - 1
        let lessThanCountToCheckOffGoal = countToCheckOffGoal - 1
        
        switch displayMode {
        case .goalMode:
            print(#function + " Goal Mode - do nothing ")
        case .taskMode:
            print(#function + " Task Mode - checkCountOfCheckedCells ")
            
            // Get all checked cells
            let checkedCellsInView = totalCells.filter( { $0.taskMarker.isHighlighted == true } )
            // Get all checked cells in section 1
            var checkedCells = [TaskCell]()
            for cell in checkedCellsInView {
                if historyTableView.indexPath(for: cell)?.section == 1 {
                    checkedCells.append(cell)
                }
            }
            print(#function + "checked/total - \(checkedCells.count) : \(countToCheckOffGoal)")
            // First Cell
            guard let firstCell = historyTableView.cellForRow(at: [0,0]) as? TaskCell else { return }
            print(#function + " firstCell")
            // If count to check goal was reached - check off goal cell and save
            if checkedCells.count == countToCheckOffGoal {
                firstCell.taskMarker.isHighlighted = true
                selectedGoal?.isChecked = true
                goalDC.saveContext()
            playCompletionAnimationForGoalIn(cell: firstCell)
                
                // Else if checkedCells are less than count needed to complete goal
                // && firstCell is checked off
            } else if checkedCells.count == lessThanCountToCheckOffGoal &&
                firstCell.taskMarker.isHighlighted == true {
                
                selectedGoal?.isChecked = false
                firstCell.taskMarker.isHighlighted = false
                
            }
            
            
            
        }
    }
    
    func playCompletionAnimationForGoalIn(cell: TaskCell) {
        backBarButton.isEnabled = false
        backBarButton.tintColor = UIColor.clear
        guard let goal = selectedGoal else { return }
        animation.playCompletionAnimationIn(view: view, of: self, withType: .history, for: goal, in: cell)
    }
    
    
    func updateCompletedTasksLabelCount() {
        print(#function)
        // Get all of the cells
        guard let visibileCells = historyTableView.visibleCells as? [TaskCell] else { return }
        // Filter for all of the checked cells
        let checkedCells = visibileCells.filter({ $0.taskMarker.isHighlighted == true })
        // Set filtered count as selectedGoal.completedGoalsCount
        selectedGoal?.completedCellCount = Int16(checkedCells.count)
        goalDC.saveContext()
        // Update label
        if displayMode == .taskMode {
            navigationItem.title = "\(selectedGoal!.completedCellCount)\\\(visibileCells.count)"
        }
        
    }
    
    
    
} // HistoryVC
 
 

