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
    var selectedGoalID = String()
    
    // MARK: - Read Me
    
    // Fetch coredata entities and reload tableView if there is data stored.
        // - Maybe display each goal and the number of completed tasks / total tasks
            // then if user selects a goal take user into another view or reload the view? to populate it with the stored tasks within a goal with the goal at the top section like in TodayVC
            // similarly, when a user selects on a cell it will take you to detail view
    
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        // reload Goals
        goalDC.fetchGoals()
    }
    
// MARK: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // maybe divide sections up by days?
            // each goal is made on a new day so no 
        return goalDC.pastGoalContainer.count
    }
    
// MARK: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

// MARK: Title for Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if goalDC.pastGoalContainer.count != 0 {
            title = "\(goalDC.formatDate(from: goalDC.pastGoalContainer[section]) ?? "DEFAULT VALUE")"
        }
        return title
    }
    
// MARK: reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskCell = "taskCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as! TaskCell
        
        if goalDC.pastGoalContainer.count != 0 {
            
            let row = indexPath.row
            let section = indexPath.section
            if section == row {
            cell.textField.text = goalDC.pastGoalContainer[row].name
            }
        } else {
            cell.textField.text = "Data did not fetch"
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
            }
        }
        
    }
    
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
