//
//  DetailExtension.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/18/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//
import UIKit
import Foundation

extension DetailTableView {
    
    // Setup for ViewDidLoad()
    func configure() {
        // handle keyboard
        addDoneButton(to: notesField, action: nil)
        addDoneButton(to: titleInput, action: nil)
        // hide update button
        updateButton.isEnabled = false
        // Set TitleInput && progress
        interpretSearchTag(withType: searchDataType)
        // set hightlighted state for marker buttons
        setHighlightedImages()
    }
    
    // set hightlighted state for marker buttons
    func setHighlightedImages() {
        blueButton.setImage(#imageLiteral(resourceName: "(Blue) Checked"), for: .selected)
        greenButton.setImage(#imageLiteral(resourceName: "(Green) Checked"), for: .selected)
        greyButton.setImage(#imageLiteral(resourceName: "(Grey) Checked"), for: .selected)
        pinkButton.setImage(#imageLiteral(resourceName: "(Pink) Checked"), for: .selected)
        redButton.setImage(#imageLiteral(resourceName: "(Red) Checked"), for: .selected)
        yellowButton.setImage(#imageLiteral(resourceName: "(Yellow) Checked"), for: .selected)
    }
    
    // Search Tag Extraction - put fetch(withTag) in here
    func interpretSearchTag(withType type: DataType) {
        print(#function)
        switch type {
        case .goal:
            standInGoal = goalDC.fetchGoal(withUID: searchUID)
            // Set title
            titleInput.text = standInGoal.name
            // Set Progress
            progressControl.selectedSegmentIndex = Int(standInGoal.progress)
            // Set Marker Color
            guard let currentColor = taskColors(rawValue: standInGoal.markerColor) else { return }
            markerColor = currentColor
            handleMarkerSelection()
            print("\(currentColor.rawValue)")
            // Set Notes
            notesField.text = standInGoal.notes
            
        default: // Task/Bonus
            standInTask = taskDC.fetchTask(with: searchUID)
            // Set Title
            titleInput.text = standInTask.name
            // Set Progress
            progressControl.selectedSegmentIndex = Int(standInTask.progress)
            // Set Color
            guard let currentColor = taskColors(rawValue: standInTask.markerColor) else { return }
            markerColor = currentColor
            handleMarkerSelection()
            // Set Notes
            notesField.text = standInTask.notes
            
        }
    }
    
    // Set Marker Color for coredata element
    func saveMarkerColor(as tag: taskColors) {
        switch searchDataType {
        case .goal:
            markerColor = tag
            standInGoal.markerColor = tag.rawValue
            goalDC.save(context: goalDC.context)
        default:
            markerColor = tag
            standInTask.markerColor = tag.rawValue
            taskDC.saveContext()
        }
    }
    
    // Interperate marker selection
    func handleMarkerSelection() {
        switch markerColor {
        case .blue:
            blueButton.isSelected = true
        case .green:
            greenButton.isSelected = true
        case .grey:
            greyButton.isSelected = true
        case .pink:
            pinkButton.isSelected = true
        case .red:
            redButton.isSelected = true
        case .yellow:
            yellowButton.isSelected = true
        }
    }
    
    
    
    
    
    
}
