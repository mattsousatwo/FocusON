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
 
