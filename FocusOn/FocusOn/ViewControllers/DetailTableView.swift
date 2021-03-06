//
//  DetailTableView.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/4/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class DetailTableView: UITableViewController {

    var newTask = Tasks(title: "", date: Date(), goal_UID: "", task_UID: "")

    // Update Button Reference
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    // text input field
    @IBOutlet weak var titleInput: UITextField!
    // Seg Controller - Beginning, In-Progress, Complete
    @IBOutlet weak var progressControl: UISegmentedControl!
    
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
        
        // can change to variable describing DataObject - set color of DataObject
        var currentColor = taskColors.blue
        
        switch (sender as! UIButton).tag {
        case 0:
            print("blue")
            currentColor = .blue
        case 1:
            print("green")
            currentColor = .green
        case 2:
            print("grey")
            currentColor = .grey
        case 3:
            print("pink")
            currentColor = .pink
        case 4:
            print("red")
            currentColor = .red
        case 5:
            print("yellow")
            currentColor = .yellow
        default:
            print("\(currentColor)")
            print("NO MARKER SELECTED")
        }
        
    }
    

    
    // variable to store titleInput text
    var something = ""
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleInput.text = something
        print("-- DetailVC.viewWillAppear = \(something)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButton.isEnabled = false
        //1 
        titleInput.text = something
        print("-- DetailVC.viewDidAppear = \(something)")
        
  
        addDoneButton(to: notesField, action: nil)
        addDoneButton(to: titleInput, action: nil)
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - BUTTONS
    
    // update button
    @IBAction func updateButtonPressed(_ sender: Any) {
        print("UpdateButton - Pressed")
            
       performSegue(withIdentifier: "unwindToTodayVC", sender: self)
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
    
    
    
    
    
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation
    
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "unwindToTodayVC" {
            
            let input = titleInput.text
            
            newTask.taskTitle = input ?? "input didnt work"
            
        }
    }
    

}

