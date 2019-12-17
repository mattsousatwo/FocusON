//
//  KeyboardManagment.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/9/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Adding toolbar to textField
    func addDoneButton(to textField: UITextField, action optionalAction: Selector?) {
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        var button = UIBarButtonItem()
        let buttonTitle = "Done"
        
        // can add an ibaction
        if let chosenAction = optionalAction {
            button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: chosenAction)
        } else {
            button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(doneButtonAction))
        }
        
        toolbar.setItems([flexSpace, button], animated: false)
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
    }
    
    // default action for done button
    @objc func doneButtonAction() {
           self.view.endEditing(true)
            print("dismiss keyboard")
           
       }
    
    // Adding toolbar to textView
    // MARK: D.R.Y.!!! -- should figure out how repeate as little as possible
    func addDoneButton(to textView: UITextView, action optionalAction: Selector?) {
        
           let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
           
           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           
           var button = UIBarButtonItem()
           let buttonTitle = "Done"
           
           // can add an ibaction
           if let chosenAction = optionalAction {
               button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: chosenAction)
           } else {
               button = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(doneButtonAction))
           }
           
           toolbar.setItems([flexSpace, button], animated: false)
           toolbar.sizeToFit()
           
           textView.inputAccessoryView = toolbar
           
           
       }
    
}

 
