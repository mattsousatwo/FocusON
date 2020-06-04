//
//  TodayVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/5/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit
import CoreData


class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TaskCellDelegate {
    
    let taskDC = TaskDataController() 
    let goalDC = GoalDataController()
    var todaysGoal = GoalData()
    var bonusCellCount = 1
    var currentGoal = GoalData()
    var searchUID = String()
    var searchDataType = DataType.goal
    var lastDeletedTask: TaskData?
    var lastDeletedTaskIndex: IndexPath?
    let animation = Animations()
   
    // Label to display task count
    @IBOutlet weak var taskCountLabel: UILabel!
    // Table View for today vc
    @IBOutlet weak var todayTable: UITableView!
    // Add Button in nav bar
    @IBOutlet weak var addTaskButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
//        goalDC.deleteAll()
//         taskDC.deleteAllTasks()
        
//        goalDC.getGoals()
        configureTodayVC()
    
        
        
    //        goalDC.createTestGoals()
    //    taskDC.createGoalWithTasks()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureViewDidAppear()
    }

    // Add a new task at bottom of table view if three cells are filled
    @IBAction func addTaskButtonWasPressed(_ sender: Any) {
        presentNewTaskAlertController()
    }
    
    // MARK: - TaskCellDelegate
    // When a task marker is pressed in a cell
    func didTaskCell(_ cell: TaskCell, change marker: Bool) {
       


        taskMarkerWasPressed(marker, cell)
        
    }
    
    // Change Colors for Task Marker
    func updateTaskMarkers(_ cell: TaskCell) {
        
        guard let firstCell = todayTable.cellForRow(at: [0,0]) as? TaskCell else { return }
        if cell == firstCell {
            guard let markerSelection = taskColors(rawValue: todaysGoal.markerColor) else { return }
            cell.taskMarker.changeImageSet(to: markerSelection)
            print(#function)
        } else {
            guard let cellIndexPath = todayTable.indexPath(for: cell) else { return }
            let task = taskDC.currentTaskContainer[cellIndexPath.row]
            guard let markerSelection = taskColors(rawValue: task.markerColor) else { return }
            cell.taskMarker.changeImageSet(to: markerSelection)
            print(#function)
        }
            
    }
    
    
     // MARK: - todayTableView Setup
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: // Goal
            return 1
        case 1: // Task
            return taskDC.currentTaskContainer.count // - needs to equal number of selected tasks - or 3 as default?
        default:
            return 1
        }
    }
    
    // MARK: Cell Creation 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let taskCell = "taskCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
        
        
        addDoneButton(to: cell.textField, action: #selector(doneButtonAction(sender:)))
        
        // segue recognizer
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuButtonPressed))
        
        cell.menuButton.addGestureRecognizer(menuTap)
    
        // remove higlighting from cell
        cell.selectionStyle = .none
        // Setting cell to be the delegate of TaskCellDelegate
        cell.delegate = self
        
        switch indexPath.section {
        case 0: // Goal Section
            print("Goal was created")
            if todaysGoal.name! == "" {
                cell.textField.placeholder = "New Goal"
            } else {
            cell.textField.text = todaysGoal.name!
            }
//            cell.taskMarker.isHighlighted = todaysGoal.isChecked
            // Change Markers to selected Color
            guard let markerSelection = taskColors(rawValue: todaysGoal.markerColor) else { return cell }
            print("markerSelection = \(markerSelection.rawValue)")
            
            updateMarkerColor(for: cell, to: markerSelection, highlighted: todaysGoal.isChecked)
            
    
        case 1: // Task Section
            print("Task was created \(indexPath.row)")
            if taskDC.currentTaskContainer.count != 0 {
                let task = taskDC.currentTaskContainer[indexPath.row]
                cell.textField.text = task.name
                guard let markerSelection = taskColors(rawValue: task.markerColor) else { return cell }
                updateMarkerColor(for: cell, to: markerSelection, highlighted: task.isChecked)
            }
            
        default:
            cell.textField.placeholder = "New Task"
        }
        
        
        
        return cell
    }

    
    // header for section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = ""

        if taskDC.currentTaskContainer.count == 0 {
            if section == 0 {
                title = "Daily Goal"
            }
        } else if taskDC.currentTaskContainer.count != 0 {
            switch section {
            case 0:
                title = "Daily Goal"
            case 1:
                title = "Tasks"
            default:
                title = "default title"
            }
        }
        
        
        return title
    }
    
    
    
    // keyboard done button - maybe update goal?
    @objc override func doneButtonAction(sender: UITextField) {
           self.view.endEditing(true)
        
        print(#function)
    
       }
    
    
    //MARK: Saving a cell -  When user is done editing in Task Cell text field
    @IBAction func editingGoalCellDidEnd(_ sender: UITextField) {
        saveTextFrom(sender: sender)
    }
    
    
    // MARK: Deselecting a cell
    // deselcting row will hide menu button
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let x = tableView.cellForRow(at: indexPath) as! TaskCell
        x.menuButton.isHidden = true
        x.isHighlighted = true
        searchUID = ""
    }
      
    // MARK: Selecting a Cell
    // if user selects a row - show menu button
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let x = tableView.cellForRow(at: indexPath) as! TaskCell
        
        if x.textField.text != "" {
            x.menuButton.isHidden = false
              x.isHighlighted = false // shown
              
              // Sending data to a container to then be loaded in detailView
              switch indexPath.section {
              case 0:
                  // Goal
                  guard let goalID = todaysGoal.goal_UID else { return }
                  print("TESTING - " + goalID)
                  searchUID = goalID
                  searchDataType = .goal
              case 1:
                  // Tasks
                  ///// If Task is saved out of row order, this will cause errors with selecting the correct task
                  print("task selected")
            //      x.menuButton.isHidden = true // hidden
                  if taskDC.currentTaskContainer.count != 0 {
                      guard let taskID = taskDC.currentTaskContainer[indexPath.row].task_UID else { return }
                  
                      print("TESTING - " + taskID)
                      searchUID = taskID
                      searchDataType = .task
                  }
                  
              default:
                  print("No Search Tag Found")
              }
        } else {
            print("Textfield at index \(indexPath) is empty") 
        }
        
        let cell = todayTable.cellForRow(at: todayTable.indexPathForSelectedRow!)
        if cell?.isEditing == true {
            cell?.isSelected = false
            
        }
             
     }
 
    // MARK: - Deleting a cell
    // Can edit cell if cell is made after 3rd task cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        case 1:
            if indexPath.row > 2 {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }
    
    // Enabling trailing swipe actions for cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction]
        
        guard let task = taskDC.currentTaskContainer[indexPath.row] as TaskData? else { return nil }
        
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete") { (action, view, actionPreformed) in
            print("Delete Button Active")
            
            self.lastDeletedTask = task
            self.lastDeletedTaskIndex = indexPath
            // MARK: DELETE TASK FUNC GOES HERE
            // self.taskDC.delete(task: task.task_UID!)
            self.taskDC.deleteCurrentTask(at: indexPath, in: self.todayTable)
            self.updateTaskCountAndNotifications()
            self.todayTable.reloadData()
        }
        let completeButton = UIContextualAction(style: .normal, title: "Complete") { (action, view, actionPreformed) in
            print("Complete Button Active")
            task.progress = 2
            self.taskDC.saveContext()
            actionPreformed(true)
        }
        completeButton.backgroundColor = #colorLiteral(red: 0.003390797181, green: 0.4353298545, blue: 0.7253979445, alpha: 1)
        let inProgressButton = UIContextualAction(style: .normal, title: "In-Progress") { (action, view, actionPreformed) in
            print("In-Progress Button Active")
            task.progress = 1
            self.taskDC.saveContext()
            actionPreformed(true)
        }
        inProgressButton.backgroundColor = #colorLiteral(red: 0.3998935819, green: 0.6000403762, blue: 0.7998998761, alpha: 1)
        let beginningButton = UIContextualAction(style: .normal, title: "Beginning") { (action, view, actionPreformed) in
            print("Beginning Button Active")
            task.progress = 0
            self.taskDC.saveContext()
            actionPreformed(true)
        }
        beginningButton.backgroundColor = #colorLiteral(red: 0.09408376366, green: 0.156873703, blue: 0.1450745761, alpha: 1)
        
        actions = [deleteButton, completeButton, inProgressButton, beginningButton]
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // User shook phone (Undo)
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            guard let lastDeletedTask = lastDeletedTask, let lastDeletedIndexPath = lastDeletedTaskIndex else { return }
            todayTable.beginUpdates()
            
            taskDC.currentTaskContainer.insert(lastDeletedTask, at: lastDeletedIndexPath.row)
            
            todayTable.insertRows(at: [lastDeletedIndexPath], with: .automatic)
            
            todayTable.endUpdates()
        }
        lastDeletedTask = nil
        lastDeletedTaskIndex = nil
        
        updateTaskCountAndNotifications()
    }

    
    // MARK: - Navigation
    // menu button to segue to detailVC
    @objc func menuButtonPressed() {
        print(#function)
        performSegue(withIdentifier: "TodayToDetail", sender: nil)
    }
     
  
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
        if segue.identifier == "TodayToDetail" {
            let nav = segue.destination as! UINavigationController
            let detailVC = nav.topViewController as! DetailTableView

            print("-----------successful segue")
            
            //MARK: - trying to set cell input to detail view if there is one set
            if let selectedIndex = todayTable.indexPathForSelectedRow {
                let x = todayTable.cellForRow(at: selectedIndex) as! TaskCell
            
                if let textInput = x.textField.text {
                    
//                    detailVC.goalTitle = textInput
                        print("text: \(textInput)\nindex: \(selectedIndex)")
                    
                    
                    // pass selected cells UID to next view and load GoalData by the UID predicate
                    detailVC.searchUID = searchUID
                    detailVC.searchDataType = searchDataType
                    detailVC.previousView = .today
                    print("searchUID: \(searchUID)\ndataType: \(searchDataType)\n")
                   //  detailVC.standInGoal = goalDC.fetchGoal(withUID: todaysGoal.goal_UID!)
                    x.menuButton.isHidden = true
                    
                } else {
                    
                }
                
            }
            
        }
        searchUID = ""
        
        
}


    @IBAction func unwindToTodayVC(segue: UIStoryboardSegue) {
        
        // check for correct segue
        guard segue.identifier == "unwindToTodayVC" else { return }
        
      
    }
    
    
}
    
    

 
 
