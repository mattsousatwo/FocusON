//
//  NotificationControl.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/6/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import UserNotifications

extension TodayVC {
    
        // Handle the title and body of each notification - called when count of tasks is altered
    func manageLocalNotifications() {
        var totalTasks = 0
        var completedTasks = 0
        var isGoalTextfieldEmpty = false
        
        guard let goalCell = todayTable.cellForRow(at: [0,0]) as? TaskCell else { return }
        if goalCell.textField.text == "" {
            isGoalTextfieldEmpty = true
        } else {
            isGoalTextfieldEmpty = false
        }
        
        guard let visibleCells = todayTable.visibleCells as? [TaskCell] else { return }
        if visibleCells.count != 0 {
            totalTasks = visibleCells.count
            var checkedCells = 0
            for cell in visibleCells {
                if cell.taskMarker.isHighlighted == true {
                    checkedCells += 1
                }
            }
            completedTasks = checkedCells
        }
        
        var title: String?
        var body: String?
        
        if totalTasks == 0 {
            title = "Its lonley here"
            body = "Add some tasks!"
        }
        else if completedTasks == 0 {
            title = "Get started!"
            body = "You've got \(totalTasks) to go!"
        } else if completedTasks < totalTasks {
            title = "Progress in Action!"
            body = "\(completedTasks) down \(totalTasks - completedTasks) left to go!"
        }
        
        scheduleLocalNotification(title: title, body: body)
        createNewGoalNotification(isGoalTextfieldEmpty) 
    }

    // Handles when and how a local notification will be triggered
    func scheduleLocalNotification(title: String?, body: String?) {
        let identifier = "FocusOnNotificationIdentifier"
        let notificationCenter = UNUserNotificationCenter.current()
        
        // remove previously scheduled notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        if let newTitle = title, let newBody = body {
            // create content
            let content = UNMutableNotificationContent()
            content.title = newTitle
            content.body = newBody
            content.sound = UNNotificationSound.default
            
            // create Trigger - 3 hours
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: false)
            // create request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            // add notification to notification center
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
        
    // send goal notification if there are no tasks set
    func createNewGoalNotification(_ goalIsEmpty: Bool) {
        if goalIsEmpty == true {
            let identifier = "NewGoalNotification"
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
            let content = UNMutableNotificationContent()
            content.title = ""
            content.body = ""
            content.sound = UNNotificationSound.default
            // every 6 hours
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 21600, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }
        
    }
    
}
