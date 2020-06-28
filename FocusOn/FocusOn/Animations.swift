//
//  Animations.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/26/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class Animations {
    
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var currentAnimation: AnimationNames?
    
    
    // Start confetti and check animation
    func playCompletionAnimationIn(view: UIView, of parent: UIViewController, withType type: Views, for goal: GoalData, in taskCell: TaskCell) {
        guard currentAnimation == nil else {
            animationPrint("currentAnimation == \(currentAnimation!.rawValue)")
            animationPrint("RETURN")
            return
        }

        animationPrint(AnimationNames.check.rawValue)
        
        // Set Current Animation
        currentAnimation = .check
        // CreateViews
        var checkView = AnimationView()
        var confettiView = AnimationView()
        // Set Animations
        checkView = .init(name: AnimationNames.check.rawValue)
        confettiView = .init(name: AnimationNames.confetti.rawValue)
        // Set Frames
        checkView.frame = view.bounds
        confettiView.frame = view.bounds
        // Add to view
        view.addSubview(checkView)
        view.addSubview(confettiView)
        // Play animations
        view.isUserInteractionEnabled = false
        confettiView.play(fromFrame: CheckAnimationFrames.start.rawValue, toFrame: CheckAnimationFrames.finished.rawValue, loopMode: .none) { (_) in
            print("complete")
            // Activate Alert Controller
            self.presentCongragulationsAlert(inParent: parent, child: view, in: type, update: goal, in: taskCell, message: .completionMessage, completion: {
                // Dismiss views upon completion
                checkView.removeFromSuperview()
                confettiView.removeFromSuperview()
                self.currentAnimation = nil
             })
         }
        checkView.play(fromFrame: ConfettiAnimationFrames.start.rawValue, toFrame: ConfettiAnimationFrames.midPoint.rawValue, loopMode: .none)
        
     }
    
    // Resume Check & Confetti Animation
    func resumeGoalAnimations(in view: UIView, parent: UIViewController, ofType type: Views) {
        if currentAnimation != nil {
            return
        }
        animationPrint(#function)
        // Set Current Animation
        currentAnimation = .check
        // Create Views
        var checkView = AnimationView()
        var confettiView = AnimationView()
        // Set Animations
        checkView = .init(name: AnimationNames.check.rawValue)
        confettiView = .init(name: AnimationNames.confetti.rawValue)
        // Set Frame
        checkView.frame = view.bounds
        confettiView.frame = view.bounds
        // Add to view
        view.addSubview(checkView)
        view.addSubview(confettiView)
        self.animationPrint("View Type = " + type.rawValue)
        // Resume animation
        confettiView.play(fromFrame: ConfettiAnimationFrames.midPoint.rawValue, toFrame: ConfettiAnimationFrames.end.rawValue, loopMode: .none) { (_) in
            confettiView.removeFromSuperview()
            self.currentAnimation = nil
        }
        checkView.play(fromFrame: CheckAnimationFrames.finished.rawValue, toFrame: CheckAnimationFrames.start.rawValue, loopMode: .none) { (_) in
            checkView.removeFromSuperview()
            view.isUserInteractionEnabled = true
            
            if type == .history {
                // Enable History navigation buttons
                guard let history = parent as? HistoryVC else { return }
                print("Animation - resume - Enable Back Button ")
                history.backBarButton.isEnabled = true
                history.backBarButton.tintColor = UIColor.blue
                self.currentAnimation = nil
            }
        }
        
    }
    
    // Pause Animation and Present Alert Controller
    func presentCongragulationsAlert(inParent view: UIViewController, child: UIView, in viewType: Views, update: Any, in taskCell: TaskCell, message: AlertMessage, completion: @escaping () -> Void) {
        let goalIndex: IndexPath = [0,0]
        // Type Cast Correct entity
        var goal: GoalData?
        var task: TaskData?
        if update is GoalData {
            guard let inputGoal = update as? GoalData else { return }
            goal = inputGoal
        } else if update is TaskData {
            guard let inputTask = update as? TaskData else { return }
            task = inputTask
        }
        // Check task or goal & resume animations
        func taskEntityIsChecked(_ checked: Bool) {
            if let goal = goal {
                goal.isChecked = checked
                self.goalDC.saveContext()
                self.resumeGoalAnimations(in: child, parent: view, ofType: viewType)
            } else if let task = task {
                task.isChecked = checked
                self.taskDC.saveContext()
                self.resumeTaskAnimation(in: child, parent: view, ofType: viewType, ofStyle: message)
                print(#function + " \(message)")
            }
        }
        // Handle title interpretation
        var title = ""
        switch message {
        case .completionMessage:
            title = "Congragulations!"
            print(title)
            print(message.rawValue)
        case .checkedTaskMessage:
            title = "Good Job!"
            print(title)
            print(message.rawValue)
        case .unCheckedTaskMessage:
            title = "Incomplete"
            print(title)
            print(message.rawValue)
        }
        // Set Message
        let x = UIAlertController(title: title, message: message.rawValue, preferredStyle: .alert)
        
        // Check off goal
        let checkGoalButton = UIAlertAction(title: "Check", style: .default, handler: { (_) in
            completion()
            taskEntityIsChecked(true)
            taskCell.taskMarker.isHighlighted = true
            child.isUserInteractionEnabled = true
        })
        
        // Leave goal unchecked
        let uncheckGoalButton = UIAlertAction(title: "Uncheck", style: .cancel) { (_) in
            completion()
            taskEntityIsChecked(false)
            taskCell.taskMarker.isHighlighted = false
            // Update completed task count
            if let history = view as? HistoryVC {
                history.updateCompletedTasksLabelCount()
            } else if let today = view as? TodayVC {
                today.updateTaskCountAndNotifications()
            }
            child.isUserInteractionEnabled = true
        }
        
        // Add buttons & dismiss
        x.addAction(checkGoalButton)
        x.addAction(uncheckGoalButton)
        view.present(x, animated: true)
    }
    
    // Start Check or Uncheck Animation for a task based on the messsge input
    func playTaskAnimation(in view: UIView, of parent: UIViewController, withType type: Views, for task: TaskData, in taskCell: TaskCell, ofStyle style: AlertMessage) {
        // Check if another animation is running
        if currentAnimation == .check {
            return
        }
        // Placeholder for start and finish
        var start: CGFloat = 0
        var finish: CGFloat = 0
        // Create Views
        var checkView = AnimationView()
        // Set Animation
        //// Set start and finish
        if style == .checkedTaskMessage {
            print(#function + " \(AnimationNames.taskCheck)")
            checkView = .init(name: AnimationNames.taskCheck.rawValue)
            start = CheckTaskAnimationFrames.start.rawValue
            finish = CheckTaskAnimationFrames.midPoint.rawValue
            // Set Current Animation
            currentAnimation = .taskCheck
            animationPrint(AnimationNames.taskCheck.rawValue)
            
        } else if style == .unCheckedTaskMessage {
            print(#function + " \(AnimationNames.uncheckTask)")
            checkView = .init(name: AnimationNames.uncheckTask.rawValue)
            start = UncheckTaskAnimationFrames.start.rawValue
            finish = UncheckTaskAnimationFrames.midPoint.rawValue
            // Set Current Animation
            currentAnimation = .uncheckTask
            animationPrint(AnimationNames.uncheckTask.rawValue)
            
        }
        // set frame
        checkView.frame = view.bounds
        // add to view
        view.addSubview(checkView)
        // play
        view.isUserInteractionEnabled = false
        checkView.play(fromFrame: start, toFrame: finish, loopMode: .none) { (_) in

            self.presentCongragulationsAlert(inParent: parent, child: view, in: type, update: task, in: taskCell, message: style) {
                // dissmiss views
                checkView.removeFromSuperview()
                self.currentAnimation = nil
            }
        } // Play()
        
    }
    
    // Resume Check or Uncheck Animation for a task
    func resumeTaskAnimation(in view: UIView, parent: UIViewController, ofType type: Views, ofStyle style: AlertMessage) {
        // Check if another animation is running
        if currentAnimation == .check {
            return
        }
        // Placeholder for start and finish
        var start: CGFloat = 0
        var finish: CGFloat = 0
        // Create Views
        var checkView = AnimationView()
        // Set Animation
        //// Set start and finish
        if style == .checkedTaskMessage {
            print(#function + " \(AnimationNames.taskCheck)")
            checkView = .init(name: AnimationNames.taskCheck.rawValue)
            start = CheckTaskAnimationFrames.midPoint.rawValue
            finish = CheckTaskAnimationFrames.end.rawValue
            // Set Current Animation
            currentAnimation = .taskCheck
        } else if style == .unCheckedTaskMessage {
            print(#function + " \(AnimationNames.uncheckTask)")
            checkView = .init(name: AnimationNames.uncheckTask.rawValue)
            start = UncheckTaskAnimationFrames.midPoint.rawValue
            finish = UncheckTaskAnimationFrames.end.rawValue
            // Set Current Animation
            currentAnimation = .uncheckTask
        }
        // Set frame
        checkView.frame = view.bounds
        // add to view
        view.addSubview(checkView)
        // play
        checkView.play(fromFrame: start, toFrame: finish, loopMode: .none) { (_) in
            checkView.removeFromSuperview()
            view.isUserInteractionEnabled = true
            self.currentAnimation = nil
        } // Play
    }
    
    
    
    
    // Debugger output
    func animationPrint(_ input: String) {
        let prefix = "Animation: "
        print(prefix + input)
    }
    
}

enum AnimationNames: String {
    case check = "check",
    confetti = "confetti",
    taskCheck = "completeTask",
    uncheckTask = "uncheckTask"
    
}

enum CheckAnimationFrames: CGFloat {
    case start = 0
    case finished = 31
    case end = 41
}

enum ConfettiAnimationFrames: CGFloat {
    case start = 0
    case midPoint = 36
    case end = 59
}

enum CheckTaskAnimationFrames: CGFloat {
    case start = 0
    case midPoint = 15
    case end = 19
}

enum UncheckTaskAnimationFrames: CGFloat {
    case start = 0
    case midPoint = 30
    case end = 40
}

enum AlertMessage: String {
    case completionMessage = "You've checked off all your tasks! Should we mark this goal as completed or is there still more to do?"
    case checkedTaskMessage = "You can do it! Success starts here!"
    case unCheckedTaskMessage = "We all need to give our selves a break sometimes"
}
