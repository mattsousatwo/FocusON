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
    
    
    // Create filter to sort which undoDelete method to trigger (time, displayMode)
    func filterUndoRequest() {
        switch displayMode {
        case .goalMode:
            goalDC.undoDeleteGoal()
        case .taskMode:
            guard let goal = selectedGoal else { return }
            taskDC.undoLastDeletedTask(inView: .history, parentGoal: goal)
            updateCompletedTasksLabelCount()
        }
        historyTableView.reloadData()
    }

  
    
    // Delete All Warning
    func presentDeleteAllWarrning() {
        let title = "Warrning: Deleting All Tasks"
        let message = "Warrning: Pressing delete will remove the goal and all tasks that are saved with it. Would you like to remove these files?"
        // Initialize AlertController
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in print("Launch Custom Action")
            
//            self.removeGoalAndTasks()
            guard let goal = self.selectedGoal else { return }
            self.goalDC.remove(goal: goal)
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
    
    // Play animation for goal
    func playCompletionAnimationForGoalIn(cell: TaskCell) {
        backBarButton.isEnabled = false
        backBarButton.tintColor = UIColor.clear
        guard let goal = selectedGoal else { return }
        animation.playCompletionAnimationIn(view: view, of: self, withType: .history, for: goal, in: cell)
    }
    
    // Update completed tasks count
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
 
 

