//
//  HistoryExtention.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/11/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
enum DisplayMode: String {
    case goalMode = "Display: GoalMode\n", taskMode = "Display: TaskMode\n"
}

import UIKit

extension HistoryVC {
    
    // Configure historyView
    func configureHistoryVC() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        goalDC.fetchGoals()
        backButtonIsHidden(true)
    }
    
    
    // Enable/Disable backBarButton & functionality of button
    func backButtonIsHidden(_ isHidden: Bool) {
        if isHidden == true {
            displayMode = .goalMode
            backBarButton.isEnabled = false
            backBarButton.tintColor = UIColor.clear
            historyTableView.reloadData()
        } else { // isHidden == false
            backBarButton.isEnabled = true
            backBarButton.tintColor = UIColor.blue
        }
        
    }
    
}
