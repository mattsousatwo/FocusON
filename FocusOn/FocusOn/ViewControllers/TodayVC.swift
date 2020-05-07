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
   
    // Label to display task count
    @IBOutlet weak var taskCountLabel: UILabel!
    // Table View for today vc
    @IBOutlet weak var todayTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayTable.dataSource = self
        todayTable.delegate = self
//        goalDC.createTestGoals()

        goalDC.deleteAll()
        taskDC.deleteAllTasks()
        
    //    taskDC.createGoalWithTasks()
        
        goalDC.fetchGoals()
        // MARK: - CREATE TEST GOALS
        //// select the history tab && then select the cell by clicking outside of the textfield, this will trigger the error
        //// in HistoryVC tableView.didSelectCellForRowAt() is where the switching of display modes is triggered  at line 151
      //  todaysGoal = taskDC.createGoalWithTasks()
        
        
        todaysGoal = goalDC.goalContainer.first!
        taskDC.fetchTasks(with: todaysGoal.goal_UID!)
        if taskDC.bonusTasksContainter.count != 0 {
            bonusCellCount = taskDC.bonusTasksContainter.count //3
            print("BonusCell inital Count \(bonusCellCount) ")
        }
        if taskDC.currentTaskContainer.count != 0 {
            print("taskContainer $$$$ == \(taskDC.currentTaskContainer.count)")
            print("taskContainer[0].name = \(taskDC.currentTaskContainer[0].name ?? "default")")
        }
        
       // todaysGoal = goalDC.fetchTodaysGoal()!
        print("todaysGoal UID: \(todaysGoal.goal_UID!)\n")
        
        
        
//        goalDC.printTimeStamps()
        print("todays Date: \(todaysGoal.dateCreated!) ")
        
        
        registerForKeyboardNotifications()
        // Inital label
        updateCompletedTasksLabel()
     //  taskCountLabel.text = "You have 0\\5 tasks completed"
        manageLocalNotifications()
    }
    
    // New task button
    @IBAction func newTaskButtonWasPressed(_ sender: Any) {
        // trigger Action controller
            // then save task
            // reload table
        // MARK :: Execute an Action Sheet Style Alert Controller by:
            
        // Initialize AlertController
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
            self.todayTable.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in print("Cancel Action")
        }
            
        
        alertController.addAction(addTask)
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {
            // Code to be run after view is displayed
        }
        
    }
    
    
    
    // MARK: - TaskCellDelegate
    // When a task marker is pressed in a cell
    func didTaskCell(_ cell: TaskCell, change marker: Bool) {
        // handle task completed count
        if marker == true {
            updateCompletedTasksLabel()
            manageLocalNotifications()
        } else if marker == false {
            updateCompletedTasksLabel()
            manageLocalNotifications()
        }
         // if firstCell { highlight all tasks }
        let firstCell = todayTable.cellForRow(at: [0,0]) as! TaskCell
        if cell == firstCell {
            // update todaysGoal
            todaysGoal.isChecked = marker
            
            print("\(cell.textField.text!)")
            if let visibleRows = todayTable.indexPathsForVisibleRows {
                for index in visibleRows {
                    let selectedCell = todayTable.cellForRow(at: index) as! TaskCell
                    selectedCell.taskMarker.isHighlighted = marker
                  
                    
                    updateCompletedTasksLabel()
                    manageLocalNotifications()
                    // Save task cell marker 
                }
            }
        }
        for cell in taskDC.currentTaskContainer {
            cell.isChecked = marker
        }
        for cell in taskDC.bonusTasksContainter {
            cell.isChecked = marker
        }
        // save context
        goalDC.saveContext()
        taskDC.saveContext()
        print("\ntodaysGoal.isChecked = \(todaysGoal.isChecked)")
        
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
            cell.taskMarker.isHighlighted = todaysGoal.isChecked
        case 1: // Task Section
            print("Task was created \(indexPath.row)")
            
            if taskDC.currentTaskContainer.count != 0 {
                cell.textField.text = taskDC.currentTaskContainer[indexPath.row].name
            }
            
//            switch indexPath.row {
//            case 0:
//                if taskDC.currentTaskContainer.count != 0 { // = more than 1
//                    cell.textField.text = taskDC.currentTaskContainer[indexPath.row].name
//                }
//            case 1:
//                if taskDC.currentTaskContainer.count >= 2 { // = 2
//                    cell.textField.text = taskDC.currentTaskContainer[indexPath.row].name
//                }
//            case 2:
//                if taskDC.currentTaskContainer.count >= 3 { // = 3
//                    cell.textField.text = taskDC.currentTaskContainer[indexPath.row].name
//                }
//            default:
//                cell.textField.placeholder = "New Task"
//            }
//        case 2: // Bonus Section
//            print("Bonus was created \(indexPath.row)")
//
//            if taskDC.bonusTasksContainter.count != 0 {
//                // MARK: SHOULD FIGURE OUT NEW IMPLEMENTATION
//                for x in 0...tableView.numberOfRows(inSection: 2) - 1 {
//                    switch indexPath.row {
//                    case x:
//                        cell.textField.text = taskDC.bonusTasksContainter[x].name
//                    default:
//                        cell.textField.placeholder = "Bonus Task"
//                    }
//                }
//                // MARK: - fix how text is selected && correct bonus cell amount is not displayed
//            } else {
//                cell.textField.placeholder = "Bonus Task"
//            }
//
        default:
            cell.textField.placeholder = "New Task"
        }
        
        return cell
    }

    
    // header for section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = ""
        
        // new section titles
        // 0: "New Task Entry"
        // 1: "Daily Goal"
        // 2: "Tasks"
        // 3: "bonus tasks"
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
        print("\(sender.text ?? "DEFAULT")")
        // MARK: - Goal Cell
        guard let firstCell = todayTable.cellForRow(at: [0,0]) as? TaskCell else { return }

        if firstCell.textField == sender && sender.text != nil {
            print("First row [0,0]")
            
            todaysGoal.name = sender.text!
            goalDC.saveContext()
            print("goal title: \(todaysGoal.name!)\ngoal date: \(todaysGoal.dateCreated!)\ngoal UID: \(todaysGoal.goal_UID!)\n...\n")
            
            // Update cell
           // goalDC.update(goal: todaysGoal)
            
        } 
        // MARK: - TASK CELL
        if taskDC.currentTaskContainer.count != 0 {
            for index in 0...taskDC.currentTaskContainer.count - 1  {

                let taskCell = todayTable.cellForRow(at: [1, index]) as! TaskCell
            
                if taskCell.textField == sender && sender.text != "" {
            
                    // MARK: Setting Task Cell position
                    let task = taskDC.currentTaskContainer[index]
                    task.name = taskCell.textField.text
                    taskDC.saveContext()
                
                }
            }
        }

//        // MARK: - Bonus Cell
//        let bonusCellRowCount = taskDC.bonusTasksContainter.count - 1
//        //  let bonusCellRowCount = bonusCellCount - 1
//        for z in 0...bonusCellRowCount {
//            let bonusCell = todayTable.cellForRow(at: [2,z]) as! TaskCell
//            if bonusCell.textField == sender && sender.text != "" {
////              taskDC.saveBonusTask(name: bonusCell.textField.text!, withGoalID: todaysGoal.goal_UID!, atPos: Int16(z))
////              bonusCellCount = taskDC.bonusTasksContainter.count
//                print("BonusCellCount = \(bonusCellCount) - before saving")
//                print("BonusCellRowCount = \(bonusCellRowCount) ")
//                // Update current bonus task
//                let bonusTask = taskDC.bonusTasksContainter[z]
//                bonusTask.name = bonusCell.textField.text
//                taskDC.saveContext()
//                // Create a new bonus task
//                taskDC.saveBonusTask(withGoalID: todaysGoal.goal_UID!)
////              bonusCellCount = taskDC.bonusTasksContainter.count
//
//                bonusCellCount += 1
//                // append indexPaths with highlighted marker
//                var highlightedIndexPaths = [IndexPath]()
//                guard let visibleIndexPaths = todayTable.indexPathsForVisibleRows else { return }
//                for row in visibleIndexPaths {
//                    let currentRow = todayTable.cellForRow(at: row) as! TaskCell
//                if currentRow.taskMarker.isHighlighted == true {
//                        highlightedIndexPaths.append(row)
//                    }
//                }
//        // reload table
//        todayTable.reloadData()
//        // set highlighted markers
//        for row in highlightedIndexPaths {
//            let currentRow = todayTable.cellForRow(at: row) as! TaskCell
//            currentRow.taskMarker.isHighlighted = true
//        }
//        // update completedTasks / totalTasks label
//        updateCompletedTasksLabel()
//        manageLocalNotifications()
//        print("BonusCellCount = \(bonusCellCount) - after saving")
//        print("BonusCellRowCount = \(bonusCellRowCount) ")
//        print("savedBonusCell.name: \(taskDC.bonusTasksContainter[z].name ?? "empty name") \nsavedBonusCell.cellPosition:  \(taskDC.bonusTasksContainter[z].cellPosition)")
//            }
//        }
//
    }
    
    
    
    // MARK: - Selecting a Cell
    // deselcting row will hide menu button
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let x = tableView.cellForRow(at: indexPath) as! TaskCell
        x.menuButton.isHidden = true
        
    }
      
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
                  
//              case 2:
//                  // Bonus
//                  // MARK: Needs new Cell Position Implementation
//                  print("bonus task selected")
//                  if taskDC.bonusTasksContainter.count != 0 {
//                      guard let taskID = taskDC.bonusTasksContainter[indexPath.row].task_UID else { return }
//                      searchUID = taskID
//                      searchDataType = .bonus
//                  }
//
              default:
                  print("No Search Tag Found")
              }
        } else {
            print("Textfield at index \(indexPath) is empty") 
        }
        
        
             
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
                    print("searchUID: \(searchUID)\ndataType: \(searchDataType)\n")
                   //  detailVC.standInGoal = goalDC.fetchGoal(withUID: todaysGoal.goal_UID!)
                    
                } else {
                    
                }
                
            }
            
        }
        
        
        
}


    @IBAction func unwindToTodayVC(segue: UIStoryboardSegue) {
        
        // check for correct segue
        guard segue.identifier == "unwindToTodayVC" else { return }
        
      
    }
    
    
}
    
    

 
 
