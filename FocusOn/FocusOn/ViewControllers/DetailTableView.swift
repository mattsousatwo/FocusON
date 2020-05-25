//
//  DetailTableView.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/4/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit
import CoreData


class DetailTableView: UITableViewController {

    var newTask = Tasks(title: "", date: Date(), goal_UID: "", task_UID: "")
    let dataControl = DataController()
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var searchUID = String()
    var searchDataType = DataType.goal
    var standInGoal = GoalData()
    var standInTask = TaskData()
    var markerColor = taskColors.blue
    var previousView: Views?
    

    // Update Button Reference
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    // text input field
    @IBOutlet weak var titleInput: UITextField!
    // Seg Controller - Beginning, In-Progress, Complete
    @IBOutlet weak var progressControl: UISegmentedControl!
    
    @IBAction func progressControlPressed(_ sender: Any) {
        // If pressed enable update button
       print("Active!")
        updateButton.isEnabled = true
    }
    
    // Goal color
    @IBOutlet weak var blueButton: UIButton! // 0
    @IBOutlet weak var greenButton: UIButton! // 1
    @IBOutlet weak var greyButton: UIButton! // 2
    @IBOutlet weak var pinkButton: UIButton! // 3
    @IBOutlet weak var redButton: UIButton! // 4
    @IBOutlet weak var yellowButton: UIButton! // 5
    
    
    // text field for any notes user has stored
    @IBOutlet weak var notesField: UITextView!
  
    
    @IBAction func markerButtonPressed(_ sender: Any) {
        updateButton.isEnabled = true
        
        guard let selectedButton = sender as? UIButton else { return }
        let buttonCollection = [blueButton, greenButton, greyButton, pinkButton, redButton, yellowButton]
        for x in buttonCollection {
            if x!.isSelected == false && x! == selectedButton {
                x!.isSelected = true
               
            } else {
                x!.isSelected = false
                selectedButton.isSelected = true
            }
        }
        
        switch (sender as! UIButton).tag {
        case 0:
            print("blue")
            
            saveMarkerColor(as: .blue)
        case 1:
            print("green")
            
            saveMarkerColor(as: .green)
        case 2:
            print("grey")
            
            saveMarkerColor(as: .grey)
        case 3:
            print("pink")
            
            saveMarkerColor(as: .pink)
        case 4:
            print("red")
            
            saveMarkerColor(as: .red)
        case 5:
            print("yellow")
            
            saveMarkerColor(as: .yellow)
        default:
            saveMarkerColor(as: .blue)
            print("NO MARKER SELECTED")
        }
    }
    
    
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(#function)
        configure()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("@DetailTableViewController" + " searchUID: \(searchUID)" )
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    // MARK: - BUTTONS
    // update button
    @IBAction func updateButtonPressed(_ sender: Any) {
        print("UpdateButton - Pressed")
        // Save Context
        let selectedProgressNum = Int16(progressControl.selectedSegmentIndex)
        
        switch searchDataType {
        case .goal:
            standInGoal.name = titleInput.text
            standInGoal.progress = selectedProgressNum
            standInGoal.notes = notesField.text
            goalDC.saveContext()
        default:
            standInTask.name = titleInput.text
            standInTask.progress = selectedProgressNum
            standInTask.notes = notesField.text
            taskDC.saveContext()

        }
        
        switch previousView {
        case .today:
            performSegue(withIdentifier: "unwindToTodayVC", sender: self)
        case .history:
            performSegue(withIdentifier: "unwindToHistoryVC", sender: self)
        default:
            return
        }

    }
    
    
    // called each time user has changed the text in titleInput field
    @IBAction func editingChanged(_ sender: Any) {
              
            print("\(titleInput.text ?? "default value")")
            
            if updateButton.isEnabled == false {
                updateButton.isEnabled = true
            } else {
                if titleInput.text == "" {
                    updateButton.isEnabled = false
                }
            }
         
    }
    
    // Overriding doneButtonAction to enable updateButton
    override func doneButtonAction(sender: UITextField) {
        print("HELLO WORLD")
        self.view.endEditing(true)
        updateButton.isEnabled = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    // higlights row when selected
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        false
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier {
        case "unwindToTodayVC":
            let input = titleInput.text
            
            newTask.taskTitle = input ?? "input didnt work"
            
            guard let todayVC = segue.destination as? TodayVC else { return }
            let selectedRow = todayVC.todayTable.indexPathForSelectedRow
            let selectedCell = todayVC.todayTable.cellForRow(at: selectedRow!) as! TaskCell
            selectedCell.textField.text = titleInput.text
            
            // func to add Image/HighlightedImage by using taskColors
            selectedCell.taskMarker.changeImageSet(to: markerColor)
            
        case "TodayToDetail":
            titleInput.text = "TodayToDetailSegue"
            print("TodayToDetail-PickedUp")
            
        case "HistoryToDetail":
            print("HistoryToDetail > DetailTableView")

        case "unwindToHistoryVC":
            print("unwindToHistoryVC Segue ")
            
            print("DetailTableView > HistoryToDetail.Segue")
            let input = titleInput.text
            newTask.taskTitle = input ?? "input did not work"
            
            guard let historyVC = segue.destination as? HistoryVC else { return }
            let selectedRow = historyVC.historyTableView.indexPathForSelectedRow
            let selectedCell = historyVC.historyTableView.cellForRow(at: selectedRow!) as! TaskCell
            selectedCell.textField.text = titleInput.text
            
            selectedCell.taskMarker.changeImageSet(to: markerColor)
            
        default:
            print("No Segue Found - DetailViewController")
        }
        
        
    }

    
}

 
