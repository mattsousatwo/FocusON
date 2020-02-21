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
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        // maybe divide sections up by days?
            // each goal is made on a new day so no 
        1
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalDC.pastGoalContainer.count
    }

    // reusable cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCell = "historyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: historyCell, for: indexPath)
        
        if goalDC.pastGoalContainer.count != 0 {
            guard let textLabel = cell.textLabel else { return cell }
            let row = indexPath.row
            textLabel.text = goalDC.pastGoalContainer[row].name
        } else {
            cell.textLabel?.text = "didnt work"
        }
         
        return cell
        
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
