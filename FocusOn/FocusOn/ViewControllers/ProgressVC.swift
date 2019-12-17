//
//  ProgressVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class ProgressVC: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let x = Goal(title: "Finish Set Up")
        print("goal title: \(x.title)\ngoal date: \(x.date)\ngoal UID: \(x.UID)\n")
        
        // add task to goal
        x.createNew(task: "create UI")
     
        x.createNew(task: "Push APP!")
        
        x.createNew(task: "last title")
     
        for n in x.tasks {
            print("\ntaskTitle: \(n.taskTitle)")
            print("taskDate: \(n.taskDate)")
            print("goal_UID: \(n.goal_UID)")
            print("task_UID: \(n.task_UID)\n")
        }
        
  
        // Do any additional setup after loading the view.
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
