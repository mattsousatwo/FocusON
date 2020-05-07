//
//  HistoryVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/5/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class HistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var selectedGoalID = String()
    var displayMode: DisplayMode = .goalMode
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        // reload Goals
        goalDC.fetchGoals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        historyTableView.reloadData()
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
            return 1
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
            var title = "" 
            if goalDC.pastGoalContainer.count != 0 {
                title = "\(goalDC.formatDate(from: goalDC.pastGoalContainer[section]) ?? "DEFAULT VALUE")"
            }
            return title
        case .taskMode:
            return nil
        }
    }
    
// MARK: reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = "taskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
        
        switch displayMode {
        case .goalMode:
            if goalDC.pastGoalContainer.count != 0 {
                
            let row = indexPath.row
            let section = indexPath.section
                if section == row {
                    cell.textField.text = goalDC.pastGoalContainer[row].name
                }
            } else {
                cell.textField.text = "Data did not fetch"
            }
            
        case .taskMode:
            let xGoal = goalDC.fetchGoal(withUID: selectedGoalID)
            taskDC.fetchTasksFor(goalUID: selectedGoalID)
            print("selectedTaskContainer \(taskDC.selectedTaskContainer.count)")
            switch indexPath.section {
            case 0: // Goal
                cell.textField.text = xGoal.name!
            case 1: // Task
                for row in 0...2 {
                    if indexPath.row == row {
                        cell.textField.text = taskDC.selectedTaskContainer[row].name!
                    }
                }
            default:
                cell.textField.text = "EMPTY "
            }
        }
        
        

        cell.textField.isUserInteractionEnabled = false
        
        return cell
        
    }
    
// MARK: Selecting a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        cell.menuButton.isHidden = false
        cell.isHighlighted = false
        
        // set variable to send to nextView
        if goalDC.pastGoalContainer.count != 0 {
            let section = indexPath.section
            if indexPath == [section, 0] {
                selectedGoalID = goalDC.pastGoalContainer[section].goal_UID!
                print("selectedGoalID = \(selectedGoalID)")
                
                displayMode = .taskMode
                print(displayMode.rawValue)
                
             //   historyTableView.beginUpdates()
             //   let task = 1
            //    let paths: [IndexPath] = [ [task, 0], [task, 1], [task, 2] ]
                
             //   historyTableView.insertRows(at: paths, with: .automatic)
                    
                historyTableView.reloadData()
              //  historyTableView.endUpdates()
                
                // use selectedGoalID to fetch for goals tasks
                // set variable to goalTaskDisplayMode
                // reload table with selected tasks
                // put switch statment on displayMode in cell creation methods
                
            }
        }
        
    }
    
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        switch displayMode {
//        case .goalMode:
//            return
//        case .taskMode:
//            historyTableView.beginUpdates()
//            let task = 1
//            let paths: [IndexPath] = [ [task, 0], [task, 1], [task, 2] ]
//         
//            historyTableView.insertRows(at: paths, with: .automatic)
//             
//            // historyTableView.reloadData()
//            historyTableView.endUpdates()
//        }
//    }
//    
    
    
    // MARK: how do insert rows?
    
    
// MARK: Deselecting a cell
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskCell
        // hide menu button
        cell.menuButton.isHidden = true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

enum DisplayMode: String {
    case goalMode = "Display: GoalMode\n", taskMode = "Display: TaskMode\n"
}
