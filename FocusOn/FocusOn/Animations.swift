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
    
    
    // Start confetti and check animation
    func playCompletionAnimationIn(view: UIView, of parent: UIViewController, withType type: Views, for goal: GoalData, in taskCell: TaskCell) {
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
            self.presentCongragulationsAlert(inParent: parent, child: view, in: type, for: goal, in: taskCell, completion: {
                // Dismiss views upon completion
                checkView.removeFromSuperview()
                confettiView.removeFromSuperview()
             })
         }
        checkView.play(fromFrame: ConfettiAnimationFrames.start.rawValue, toFrame: ConfettiAnimationFrames.midPoint.rawValue, loopMode: .none)
     }
    
    // Resume Check & Confetti Animation
    func resumeAnimations(in view: UIView, parent: UIViewController, ofType type: Views) {
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
        // Resume animation
        confettiView.play(fromFrame: ConfettiAnimationFrames.midPoint.rawValue, toFrame: ConfettiAnimationFrames.end.rawValue, loopMode: .none) { (_) in
            confettiView.removeFromSuperview()
        }
        checkView.play(fromFrame: CheckAnimationFrames.finished.rawValue, toFrame: CheckAnimationFrames.start.rawValue, loopMode: .none) { (_) in
            checkView.removeFromSuperview()
            view.isUserInteractionEnabled = true 
            if type == .history {
                // Enable History navigation buttons
                guard let history = parent as? HistoryVC else { return }
                history.backBarButton.isEnabled = true
                history.backBarButton.tintColor = UIColor.blue
            }
        }
        
    }
    
    // Pause Animation and Present Alert Controller
    func presentCongragulationsAlert(inParent view: UIViewController, child: UIView, in viewType: Views, for goal: GoalData, in taskCell: TaskCell, completion: @escaping () -> Void) {
        
        let x = UIAlertController(title: "Congragulations!", message: AlertMessage.completionMessage.rawValue, preferredStyle: .alert)
        
        // Check off goal
        let checkGoalButton = UIAlertAction(title: "Check", style: .default, handler: { (_) in
            completion()
            self.resumeAnimations(in: child, parent: view, ofType: viewType)
            goal.isChecked = true
            taskCell.taskMarker.isHighlighted = true
            self.goalDC.saveContext()
        })
        
        // Leave goal unchecked
        let uncheckGoalButton = UIAlertAction(title: "Uncheck", style: .cancel) { (_) in
            completion()
            self.resumeAnimations(in: child, parent: view, ofType: viewType)
            goal.isChecked = false
            taskCell.taskMarker.isHighlighted = false
            self.goalDC.saveContext()
        }
        
        // Add buttons & dismiss
        x.addAction(checkGoalButton)
        x.addAction(uncheckGoalButton)
        view.present(x, animated: true)
    }


}

enum AnimationNames: String {
    case check = "check",
    confetti = "confetti"
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

enum AlertMessage: String {
    case completionMessage = "You've checked off all your tasks! Should we mark this goal as completed or is there still more to do?"
}
