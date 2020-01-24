//
//  TodayVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/5/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class TodayVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    let todaysGoal = Goal()
    var bonusCellCount = 1
    
    
    // Table View for today vc
    @IBOutlet weak var todayTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayTable.dataSource = self
        todayTable.delegate = self
        
        
       
        
        registerGestures()
        registerForKeyboardNotifications()
    }
    
    // new task button gestures
    func registerGestures() {
  //     let newTaskTap = UIGestureRecognizer(target: self, action: #selector(newTaskButton(_:))) // line: 146
        

    }
    
    
    
     // MARK: - todayTableView Setup
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: // Goal
            return 1
        case 1: // Task
            return 3 // - needs to equal number of selected tasks - or 3 as default?
        case 2: // Bonus Task
            return bonusCellCount
        default:
            return 1
        }
    }
    
    // MARK: reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let taskCell = "taskCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
        
      
        addDoneButton(to: cell.textField, action: #selector(doneButtonAction(sender:)))
        
        // segue recognizer
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuButtonPressed))
        
        cell.menuButton.addGestureRecognizer(menuTap)
    
    
        switch indexPath.section {
        case 0:
            cell.textField.placeholder = "New Goal"
        case 1:
            cell.textField.placeholder = "New Task"
        case 2:
            cell.textField.placeholder = "Bonus Task"
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
        
        switch section {
        case 0:
            title = "Daily Goal"
        case 1:
            title = "Tasks"
        case 2:
            title = "Bonus Tasks"
        default:
            title = "default title"
        }
        
        return title
    }
    
    
    
    // keyboard done button - maybe update goal?
    @objc override func doneButtonAction(sender: UITextField) {
           self.view.endEditing(true)
        
        print(#function)
    
       }
    
    
    // When user is done editing in Task Cell text field - MARK: DONE EDITING CELL
    @IBAction func editingGoalCellDidEnd(_ sender: UITextField) {
        print("\(sender.text ?? "DEFAULT")")
        // MARK: - Goal Cell
        let firstCell = todayTable.cellForRow(at: [0,0]) as! TaskCell

        if firstCell.textField == sender && sender.text != nil {
            print("First row [0,0]")

            todaysGoal.title = sender.text!
            print("goal title: \(todaysGoal.title)\ngoal date: \(todaysGoal.date)\ngoal UID: \(todaysGoal.UID)\n...\n")
        }

        // MARK: - TASK CELL - IMPORTANT: taskLimit needs to equal number of rows in task section of table
        let taskLimit = 2
        for index in 0...taskLimit {

            let taskCell = todayTable.cellForRow(at: [1, index]) as! TaskCell
            
            
            if taskCell.textField == sender && sender.text != "" {
        // MARK: ERROR: When user inputs text in a cell in the tasks section, a new task is entered at the first position “tasks[0]”, not the position of the row “tasks[2]”.
                // - dont think i need to change anything to accomodate - If i set data to a coredata object it will be just fine and I wont return objects in an array ordering system
                
                todaysGoal.createNew(task: sender.text)
                if index == todaysGoal.tasks.count {
                    print("------\ntaskTitle: \(todaysGoal.tasks[index].taskTitle) \ntaskUID: \(todaysGoal.tasks[index].task_UID) \ngoalUID: \(todaysGoal.tasks[index].goal_UID)")
                }
            
               
            }
        }

        // MARK: - Bonus Cell
        let bonusCellRowCount = bonusCellCount - 1
        for z in 0...bonusCellRowCount {
            let bonusCell = todayTable.cellForRow(at: [2,z]) as! TaskCell
            
            if bonusCell.textField == sender && sender.text != "" {
                print("Hello World")
                    //   print("\(bonusCell.textField.text!)")
                       // bonus task added - do some work
                bonusCellCount += 1
                todayTable.reloadData()
            }
        }
  

        
    }
    
    // New Task button
    @objc func newTaskButton(_ sender: UITapGestureRecognizer) {
        
        print("Create New Task")
    }
    
    
    // Attempting to highlight the marker but not the cell
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    
        let z = tableView.cellForRow(at: indexPath) as! TaskCell
            
        z.isHighlighted = false
            
        z.taskMarker.isHighlighted = true
        
    }
    
    // deselcting row will hide menu button
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let x = tableView.cellForRow(at: indexPath) as! TaskCell
        x.menuButton.isHidden = true
      
    }
    
      // MARK: - Navigation
    
    // if user selects a row - preform detail segue
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let x = tableView.cellForRow(at: indexPath) as! TaskCell
        x.menuButton.isHidden = false
     }

    // menu button to segue to detailVC
    @objc func menuButtonPressed() {
        print(#function)
        performSegue(withIdentifier: "TodayToDetail", sender: nil)
    }
     
        // MARK: - passing data to detailVC not showing up
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
        if segue.identifier == "TodayToDetail" {
            let detailVC = DetailTableView()
            
            print("-----------successful segue")
            
            //MARK: - trying to set cell input to detail view if there is one set
            if let selectedIndex = todayTable.indexPathForSelectedRow {
                let x = todayTable.cellForRow(at: selectedIndex) as! TaskCell
                
                if let textInput = x.textField.text {
                    
                        detailVC.something = textInput
                        print("text: \(x.textField.text!)\nindex: \(selectedIndex)")
                    
                    
                    
                } else {
                    detailVC.something = "DEFAULT TEXT"
                }
                
            }
            
        }
}


    @IBAction func unwindToTodayVC(segue: UIStoryboardSegue) {
        
        // check for correct segue
        guard segue.identifier == "unwindToTodayVC" else {return}
        
        // reference for detailVC
        let sourceVC = segue.source as! DetailTableView
        
        
        if let selectedIndex = todayTable.indexPathForSelectedRow {
            let tableCell = todayTable.cellForRow(at: selectedIndex) as! TaskCell
            
            // MARK: - UPDATE: Section 3: need to handle 3 sections
            switch selectedIndex.section  {
            case 0: // case goal was selected
                
                // setting selected cells textField to updated title from DetailVC
                tableCell.textField.text = sourceVC.newTask.taskTitle
                
                // setting notes parameter
                todaysGoal.notes = sourceVC.notesField.text!
                
                // setting progress
                todaysGoal.setProgress(to: sourceVC.progressControl.selectedSegmentIndex)
                
            case 1: // case a task was selected
                
                // MARK: - Error - task title 
                todaysGoal.tasks[selectedIndex.row].taskTitle = sourceVC.titleInput.text!
                
                    print("------\ntaskTitle: \(todaysGoal.tasks[selectedIndex.row].taskTitle) \ntaskUID: \(todaysGoal.tasks[selectedIndex.row].task_UID) \ngoalUID: \(todaysGoal.tasks[selectedIndex.row].goal_UID)")
                    
                // setting progress
                todaysGoal.tasks[selectedIndex.row].setProgress(to: sourceVC.progressControl.selectedSegmentIndex)
                    print("\(todaysGoal.tasks[selectedIndex.row].taskProgress)")
                
                // set notes
                todaysGoal.tasks[selectedIndex.row].taskNotes = sourceVC.notesField.text!
                
            case 2:
                print("Bonus Cell Selected - Finish implementation")
                
            default:
                print("unwindToTodayVC segue")
            
            }
        }
    
        
        
    }



}
 
