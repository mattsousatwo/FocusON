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
    
    
    // Table View for today vc
    @IBOutlet weak var todayTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayTable.dataSource = self
        todayTable.delegate = self
        
        registerGestures()
        
    }
    
    // new task button gestures
    func registerGestures() {
  //     let newTaskTap = UIGestureRecognizer(target: self, action: #selector(newTaskButton(_:))) // line: 146
        

    }
    
    
    
     // MARK: - todayTableView Setup
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 3 // needs to equal number of selected tasks - or 3 as default?
        default:
            return 1
        }
    }
    
    // MARK: reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       let taskCell = "taskCell"
       let goalCell = "goalCell"
       
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: goalCell, for: indexPath) as! GoalCell
               
            addDoneButton(to: cell.textField, action: #selector(doneButtonAction))
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
            
            addDoneButton(to: cell.textField, action: #selector(doneButtonAction))
            
            // segue recognizer
            let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuButtonPressed))
            
            cell.menuButton.addGestureRecognizer(menuTap)
            
            
            return cell
        }
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
            title = "New Goal!"
        case 1:
            title = "Tasks"
        default:
            title = "default title"
        }
        
        return title
    }
    
    
    
    // keyboard done button - maybe update goal?
    @objc override func doneButtonAction() {
           self.view.endEditing(true)
    
       }
    
    
    // When user is done editing in Goal Cell text field - MARK: DONE EDITING CELL
    @IBAction func editingGoalCellDidEnd(_ sender: UITextField) {
        
        print("\(sender.text ?? "DEFAULT")")
        
        let firstCell = todayTable.cellForRow(at: [0,0]) as! GoalCell
        
        if firstCell.textField == sender && sender.text != nil {
            print("Goal Input Row")
            
            todaysGoal.title = sender.text!
            print("goal title: \(todaysGoal.title)\ngoal date: \(todaysGoal.date)\ngoal UID: \(todaysGoal.UID)\n...\n")
        }
        
        // MARK: - IMPORTANT: taskLimit needs to equal number of rows in task section of table
        let taskLimit = 2
        for index in 0...taskLimit {
            
            let taskCell = todayTable.cellForRow(at: [1, index]) as! TaskCell
            
            if taskCell.textField == sender && sender.text != "" {
                
                todaysGoal.createNew(task: sender.text)
                print("------\ntaskTitle: \(todaysGoal.tasks[index].taskTitle) \ntaskUID: \(todaysGoal.tasks[index].task_UID) \ngoalUID: \(todaysGoal.tasks[index].goal_UID)")
            }
        }
        
        
        
    }
    
    // New Task button
    @objc func newTaskButton(_ sender: UITapGestureRecognizer) {
        
        print("Create New Task")
    }
    
    
    // Attempting to highlight the marker but not the cell
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        
        switch indexPath.section {
        case 0: // New task Input
            let x = tableView.cellForRow(at: indexPath) as! GoalCell
            x.isHighlighted = false
        default: // Task Cell
            let z = tableView.cellForRow(at: indexPath) as! TaskCell
            
            z.isHighlighted = false
            
            z.taskMarker.isHighlighted = true
        }
    }
    
    // deselcting row will hide menu button
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // New Task Input
            return
        case 1: // Task Cell
            let x = tableView.cellForRow(at: indexPath) as! TaskCell
            x.menuButton.isHidden = true
        default:
            return
        }
    }
    
      // MARK: - Navigation
    
    // if user selects a row - preform detail segue
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // New Task Input
            return
        case 1: // Task Cell
            let x = tableView.cellForRow(at: indexPath) as! TaskCell
            x.menuButton.isHidden = false
        default:
            return
        }
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
                
                
                
            default:
                print("unwindToTodayVC segue")
            
            }
        }
    
        
        
    }



}
 
