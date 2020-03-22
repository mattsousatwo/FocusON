//
//  KeyboardManagment.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/9/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // default action for done button
    @objc func doneButtonAction(sender: UITextField) {
           self.view.endEditing(true)
            print("dismiss keyboard")
           
       }
    
    // Adding a toolbar to top of keyboard to dismiss keyboard with a done button
    func addDoneButton(to textView: UIView, action optionalAction: Selector?) {
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        var button = UIBarButtonItem()
        let buttonTitle = "Done"
        
        // can add an ibaction
        if let chosenAction = optionalAction {
            button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: chosenAction)
        } else {
            button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(doneButtonAction(sender:)))
        }
        
        toolbar.setItems([flexSpace, button], animated: false)
        toolbar.sizeToFit()
        
        // Checking type
        if textView is UITextField {
            let x = textView as! UITextField
            x.inputAccessoryView = toolbar
        } else if textView is UITextView {
            let y = textView as! UITextView
            y.inputAccessoryView = toolbar
        }
        
        
    }
    
}
    
extension TodayVC {
    
    // MARK: Adjusting view layout for keyboard
    
    func registerForKeyboardNotifications() {
        print(#function)
        
        // #selector()  needs to accept signature functionName(sender:)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Need to figure out how to get assigned table view to be in the scope of these functions 
    @objc func keyboardWillShow(sender: NSNotification) {
        print(#function)
        // grabbing a CGRect of the keyboard frame when our notification is called
        let keyboardFrame = sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        print(#function)
        adjustLayoutForKeyboard(targetHeight: 0)
    }
    
    private func adjustLayoutForKeyboard(targetHeight: CGFloat) {
        print(#function)
        todayTable.contentInset.bottom = targetHeight
    }
    
    // Display / update task count label 
    func updateCompletedTasksLabel() {
        taskCountLabel.text = "You have 0\\5 tasks completed"
        var tempCount: Int16 = 0
        guard let totalTasks = todayTable.visibleCells as? [TaskCell] else { return }
        if totalTasks.count != 0 {
            for task in totalTasks {
                if task.taskMarker.isHighlighted == true {
                    tempCount+=1
                }
            }
            todaysGoal.completedCellCount = tempCount
            goalDC.saveContext()
            
            taskCountLabel.text = "You have \(todaysGoal.completedCellCount)\\\(totalTasks.count) tasks completed"
        }

    }

}// todayVC

extension UIImageView {
    
    func changeImageSet(to set: taskColors) {
        switch set {
        case .blue:
            self.image = #imageLiteral(resourceName: "(Blue) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Blue) Checked")
        case .green:
            self.image = #imageLiteral(resourceName: "(Green) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Green) Checked")
        case .grey:
            self.image = #imageLiteral(resourceName: "(Grey) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Grey) Checked")
        case .pink:
            self.image = #imageLiteral(resourceName: "(Pink) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Pink) Checked")
        case .red:
            self.image = #imageLiteral(resourceName: "(Red) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Red) Checked")
        case .yellow:
            self.image = #imageLiteral(resourceName: "(Yellow) Unchecked")
            self.highlightedImage = #imageLiteral(resourceName: "(Yellow) Checked")
        }
        
    }
}
 
