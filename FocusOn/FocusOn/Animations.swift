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
    
    // Start confetti and check animation
    func playCompletionAnimationIn(view: UIView, of parent: UIViewController, withType type: Views) {
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
            self.presentCongragulationsAlert(inParent: parent, child: view, in: type, completion: {
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
                guard let history = parent as? HistoryVC else { return }
                history.backBarButton.isEnabled = true
                history.backBarButton.tintColor = UIColor.blue
            }
        }
        
    }
    
    // Pause Animation and Present Alert Controller
    func presentCongragulationsAlert(inParent view: UIViewController, child: UIView, in viewType: Views, completion: @escaping () -> Void) {
        
        var message = ""
        switch viewType {
        case .today:
            message = AlertMessage.todayMessage.rawValue
        case .history:
            message = AlertMessage.historyMessage.rawValue
        }
        
        let x = UIAlertController(title: "Congragulations!", message: message, preferredStyle: .alert)
        
        let actionButton = UIAlertAction(title: "Got It!", style: .cancel) { (_) in
            completion()
            self.resumeAnimations(in: child, parent: view, ofType: viewType)
        }
        
    
        x.addAction(actionButton)
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
    case historyMessage = "You completed your goal! Way to go!"
    case todayMessage = "You accomplished your goal! Rest up or get a head start on tomorrows goal."
}
