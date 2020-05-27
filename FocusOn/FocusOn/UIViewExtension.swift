//
//  UIViewExtension.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/24/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import UIKit


extension UITableView {
    
    // Return index of textField - used in didFinishEditing
    func getIndexPath(of textField: UITextField?) -> IndexPath? {
        guard let textField = textField else { return nil }
        guard let array = self.visibleCells as? [TaskCell] else { return nil }
        var x: IndexPath?
        for cell in array {
            if textField == cell.textField {
                x = self.indexPath(for: cell)
            }
        }
        return x
    }
    
    // If firstCell (Goal) task marker is selected, check off all tasks
    func checkGoalToUpdateTaskCells() {
        print("Marker")
        guard let firstRow = self.cellForRow(at: [0,0]) as? TaskCell else { return }
        print(#function)
        let isSelected = firstRow.taskMarker.isHighlighted
        print("Change taskMarkers.isSelected to \(isSelected)")
        updateTaskMarkersIn(sec: 1, to: isSelected)
        
    }
    
    // Check all markers in selected section
    func updateTaskMarkersIn(sec: Int, to marker: Bool) {
        guard let selectedRows = self.rowsIn(section: sec) else { return }
        for index in selectedRows {
            guard let cell = self.cellForRow(at: index) as? TaskCell else { return }
            cell.taskMarker.isHighlighted = marker
        }
    }
    
    // Return all rows in selected section
    func rowsIn(section: Int) -> [IndexPath]? {
        guard let visibleRows = self.indexPathsForVisibleRows else { return nil }
        var paths: [IndexPath]?
        for index in visibleRows {
            if index.section == section {
                paths?.append(index)
            }
        }
        return paths
    }
    
    // clear buttons
    func clearMenuButtons() {
        guard let x = self.visibleCells as? [TaskCell] else { return }
        let y = x.filter( { $0.menuButton.isHidden == false } )
        
        for cell in y {
            cell.menuButton.isHidden = true
        }
        
    }
}

extension UIViewController {
    // Update marker color for cell
      func changeMarker(for cell: TaskCell, to selector: taskColors, highlighted: Bool) {
          cell.taskMarker.changeImageSet(to: selector)
          switch highlighted {
          case true:
              cell.taskMarker.isHighlighted = highlighted
          case false:
              cell.taskMarker.isHighlighted = highlighted
          }
          
      }
}

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
 