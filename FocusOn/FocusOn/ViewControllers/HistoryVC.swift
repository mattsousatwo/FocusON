//
//  HistoryVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/5/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate {
    
    
    // Display
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var selectedGoalID = String()
    var selectedTaskID: String?
    var dataType: DataType?
    var selectedGoal: GoalData?
    var displayMode: DisplayMode = .goalMode
    // Deleted Goals & Tasks
    var lastDeletedGoal: GoalData?
    var lastDeletedGoalIndex: IndexPath?
    var lastDeletedTask: TaskData?
    var lastDeletedTaskIndex: IndexPath?
    // Delete All
    var deleteAllGoal: GoalData?
    var deleteAllGoalIndex: IndexPath?
    var deleteAllGoalPosition: Int?
    var deleteAllTasks: [TaskData]?
    var deleteAllTasksIndex: [IndexPath]?
    var goalCount = 1
    // Animation
    let animation = Animations()
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    @IBOutlet weak var newTaskButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHistoryVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureViewDidAppear()
    }
    
    // MARK: TaskCell Delegate
    func didTaskCell(_ cell: TaskCell, change marker: Bool) {
        
        // get all visible rows index
        guard let visibleRows = historyTableView.indexPathsForVisibleRows else { return }
        
        switch displayMode {
        case .goalMode:
            for index in visibleRows {
                // save goal marker as checked
                if cell == historyTableView.cellForRow(at: index) {
                let goal = goalDC.pastGoalContainer[index.row]
                goal.isChecked = marker
                print(#function)
                goalDC.saveContext()
                }
            }
        case .taskMode:
            for index in visibleRows {
                switch index {
                case [0,0]:
                    // goal
                    // save goal marker as checked
                    if cell == historyTableView.cellForRow(at: index) {
                    guard let goal = selectedGoal else { return }
                    goal.isChecked = marker
                    goalDC.saveContext()
                        // Check off all cells
                        for visibleRowIndex in visibleRows {
                            guard let visibleCell = historyTableView.cellForRow(at: visibleRowIndex) as? TaskCell else { return }
                            visibleCell.taskMarker.isHighlighted = marker
                            if visibleRowIndex.section > 0 {
                                let rowIndex = visibleRowIndex
                                let task = taskDC.selectedTaskContainer[rowIndex.row]
                                task.isChecked = marker
                            }
                        }
                    }
                default:
                    // task
                    // save task marker as checked
                    if cell == historyTableView.cellForRow(at: index) {
                        let task = taskDC.selectedTaskContainer[index.row]
                        task.isChecked = marker
                        taskDC.saveContext()
                    }
                }
            }
        }
        // Check if all task markers are complete 
        checkMarkersInRowsForCompletion()
    }
    
    // Loading task markers
    func updateTaskMarkers(_ cell: TaskCell) {
        updateMarker(for: cell)
    }
    
// MARK: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // maybe divide sections up by days?
            // each goal is made on a new day so no
        switch displayMode {
        case .goalMode:
            return goalDC.pastGoalContainer.count
        case .taskMode:
            return 2
        }
    }
    
// MARK: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch displayMode {
        case .goalMode:
            if goalDC.pastGoalContainer.count != 0 {
                return 1
            }
            return 0
        case .taskMode:
            switch section {
            case 0:
                return 1
            case 1:
                return taskDC.selectedTaskContainer.count
            default:
                return 0
            }
        }
        
    }

// MARK: Title for Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch displayMode {
        case .goalMode:
            navigationItem.title = "History"
            var title = "" 
            if goalDC.pastGoalContainer.count != 0 {
                title = "\(goalDC.formatDate(from: goalDC.pastGoalContainer[section]) ?? "DEFAULT VALUE")"
            }
            return title
        case .taskMode:
            navigationItem.title = "\( goalDC.formatDate(from: selectedGoal) ?? "History" )"
            switch section {
            case 0:
                return "Goal"
            default:
                return "Tasks"
            }
        }
    }
    
// MARK: reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = "taskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
        
        cell.delegate = self
        
        switch displayMode {
        case .goalMode:
            cell.textField.isUserInteractionEnabled = false
            if goalDC.pastGoalContainer.count != 0 {
                
            let row = indexPath.row
            let section = indexPath.section
                if section == row {
                    let goal = goalDC.pastGoalContainer[row]
                    cell.textField.text = goal.name
                    guard let markerSelection = taskColors(rawValue: goal.markerColor) else { return cell }
                    changeMarker(for: cell, to: markerSelection, highlighted: goal.isChecked)
                    printMarkerSelection(for: goal)
                }
            } else {
                cell.textField.text = "Data did not fetch"
            }
            
        case .taskMode:
            cell.textField.isUserInteractionEnabled = true
            addDoneButton(to: cell.textField, action: nil)
            switch indexPath.section {
            case 0: // Goal
                if let goal = selectedGoal {
                    cell.textField.text = goal.name!
                    guard let markerSelection = taskColors(rawValue: goal.markerColor) else { return cell }
                    changeMarker(for: cell, to: markerSelection, highlighted: goal.isChecked)
                    printMarkerSelection(for: goal)
                }
            case 1: // Task
                if taskDC.selectedTaskContainer.count != 0 {
                    let task = taskDC.selectedTaskContainer[indexPath.row]
                    if task.name != "" {
                         cell.textField.text = task.name
                    } else {
                        cell.textField.placeholder = "New Task Here"
                    }
                   
                    guard let markerSelection = taskColors(rawValue: task.markerColor) else { return cell }
                    changeMarker(for: cell, to: markerSelection, highlighted: task.isChecked)
                    printMarkerSelection(for: nil, for: task)
                }
            default:
                cell.textField.text = "EMPTY "
            }
        }
        
        
        addMenuGesture(to: cell, in: self)
        
        return cell
        
    }
    
// MARK: Selecting a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        cell.menuButton.isHidden = false

        
        switch displayMode {
        case .goalMode:
            // set variable to send to nextView
            if goalDC.pastGoalContainer.count != 0 {
                let section = indexPath.section
                    if indexPath == [section, 0] {
                        selectedGoalID = goalDC.pastGoalContainer[section].goal_UID!
                        print("selectedGoalID = \(selectedGoalID)")
                    }
                }
        case .taskMode:
            print("Seleted Row")
          // MARK: NEED TO ASSIGN TASK ROW
            switch indexPath.section {
            case 0:
                print("selected GoalID = \(selectedGoal?.goal_UID ?? "is empty")")
                
            case 1:
                if taskDC.selectedTaskContainer.count != 0 {
                    selectedTaskID = taskDC.selectedTaskContainer[indexPath.row].task_UID
                }
                
                
                
                
            default:
                print("section not found - HistoryVC > didSelectRow")
            }
            
            
            
            
        }
    }
    
// MARK: Deselecting a cell
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        // hide menu button
        cell.menuButton.isHidden = true
        selectedGoalID = ""
    }
    
    // MARK: - Deleting a Cell
    
    // Can delete Goal
    // Cannot delete tasks or goals if in taskMode
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch displayMode {
        case .goalMode:
            return true
        case .taskMode:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction]
        var title = ""
        
        if indexPath == [0,0] &&
        displayMode == .taskMode {
            title = "Delete All"
        } else {
            title = "Delete"
        }
        let deleteButton = UIContextualAction(style: .destructive, title: title) { (action, view, actionPreformed) in
            switch self.displayMode {
            case .goalMode:
                let goal = self.goalDC.pastGoalContainer[indexPath.row]
                self.delete(goal, at: indexPath, displayMode: .goalMode)
            case .taskMode:
                switch indexPath.section {
                case 0: // Goal
                    // MARK: Delete All
                    self.presentDeleteAllWarrning()
                case 1: // Task
                    // MARK: Delete single task
                    let task = self.taskDC.selectedTaskContainer[indexPath.row]
                    self.delete(task, at: indexPath)
                    self.historyTableView.reloadData()
                default:
                    return
                }
            }
        }
        
        let cancelButton = UIContextualAction(style: .normal, title: "Cancel") { (action, view, actionPreformed) in
            actionPreformed(true)
        }
        
        actions = [deleteButton, cancelButton]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // User shook phone (Undo)
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print(#function)
            // check if goal or task is used
            switch checkDeleteMode() {
            case .task: // lastTaskDeleted is != nil
                guard let deletedTask = lastDeletedTask, let deletedTaskIndex = lastDeletedTaskIndex else { return }
                // insert task back into table and array
                historyTableView.beginUpdates()
                taskDC.selectedTaskContainer.insert(deletedTask, at: deletedTaskIndex.row)
                historyTableView.insertRows(at: [deletedTaskIndex], with: .automatic)
                historyTableView.endUpdates()
            case .goal: // lastGoalDeleted is != nil
                guard let deletedGoal = lastDeletedGoal, let deletedGoalIndex = lastDeletedGoalIndex else { return }
                // Insert goal back into table and array
                historyTableView.beginUpdates()
                goalDC.pastGoalContainer.insert(deletedGoal, at: deletedGoalIndex.row)
                historyTableView.insertRows(at: [deletedGoalIndex], with: .automatic)
                historyTableView.endUpdates()
            case .deleteAll:
                print("DeleteAll")
                
                // Get goal and tasks
                guard let goal = deleteAllGoal else { return }
                print("1")
//                guard let goalIndex = deleteAllGoalIndex else { return }
                print("2")
                guard let goalPos = deleteAllGoalPosition else { return }
                print("3")
                guard let tasks = deleteAllTasks else { return }
                print("4")
                guard let tasksIndex = deleteAllTasksIndex else { return }
                print("5")
                print(goal.goal_UID ?? "")
                print(selectedGoalID)
                print(displayMode)
                // Insert rows
                goalDC.pastGoalContainer.insert(goal, at: goalPos)
                
                for index in tasksIndex {
                    for task in tasks {
                        taskDC.pastTaskContainer.insert(task, at: index.row)
                    }
                }
                
                if goal.goal_UID! == selectedGoalID {
                    print("should insert rows")
                    selectedGoal = goal
                    for index in tasksIndex {
                        for task in tasks {
                            taskDC.selectedTaskContainer.insert(task, at: index.row)
                        }
                    }

                }
                historyTableView.reloadData()
            default:
                return
            }
            
            // reset deleted store
            clearDeletedCache()
            for view in historyTableView.visibleCells {
                guard let view = view as? TaskCell else { return }
                view.menuButton.isHidden = true
            }
            navigationItem.title = "History"
            historyTableView.reloadData()
            
        }
    }
    
    
    
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print(#function)
        switch segue.identifier {
        case "HistoryToDetail":
            guard let navigation = segue.destination as? UINavigationController else { return }
            guard let detailVC = navigation.topViewController as? DetailTableView else { return }
            
            guard let selectedIndex = historyTableView.indexPathForSelectedRow else { return }
            guard let selectedRow = historyTableView.cellForRow(at: selectedIndex) as? TaskCell else { return }

            
            
            
            guard let searchDataType = dataType else { return }
            
            
            switch searchDataType {
            case .goal:
                print("Goals - searchID = \(selectedGoalID)")
            default:
                print("Tasks - searchID = \(selectedTaskID ?? "isEmpty")")
            }
            switch displayMode {
                
            case .goalMode:
                detailVC.searchUID = selectedGoalID
                detailVC.searchDataType = .goal
                
            case .taskMode:
                // If First Index - Goal
                if historyTableView.indexPathForSelectedRow == [0,0] {
                    print(".taskMode > Goal")
                    print("Goals 2 - searchID = \(selectedGoalID)")
                    detailVC.searchUID = selectedGoalID
                    detailVC.searchDataType = searchDataType
                    // Mark unselectRow
                    selectedRow.menuButton.isHidden = true
                //    historyTableView.deselectRow(at: selectedIndex, animated: false)
                    
                } else {
                    // Else If Task
                    print(".taskMode > Task ")
                    if taskDC.selectedTaskContainer.count != 0 {
                        guard let selectedTaskID = selectedTaskID else { return }
                        detailVC.searchUID = selectedTaskID
                        detailVC.searchDataType = searchDataType
                        selectedRow.menuButton.isHidden = true
                     //   historyTableView.deselectRow(at: selectedIndex, animated: false)
                    }
                }
                detailVC.previousView = .history
            }
        default:
            print("No Segue Found")
        }
        
        
    }
    
    @IBAction func editingTexfieldDidEnd(_ sender: Any) {
        guard let textField = sender as? UITextField else { return }
        saveTextFrom(sender: textField)
    }
    
    

    @IBAction func backBarButtonWasPressed(_ sender: Any) {
        backButtonIsHidden(true)
        newTaskButtonIsHidden(true)
    }
    
    @IBAction func newTaskButtonWasPressed(_ sender: Any) {
        presentNewTaskMessage()
    }
    
    @IBAction func unwindToHistoryVC(segue: UIStoryboardSegue) {
        
        guard segue.identifier == "unwindToHistoryVC" else { return }
        
    }
    
}

