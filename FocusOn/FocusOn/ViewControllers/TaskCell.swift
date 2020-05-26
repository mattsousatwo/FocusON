//
//  GoalCell.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/4/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    
    func didTaskCell(_ cell: TaskCell, change marker: Bool)
    
    func updateTaskMarkers(_ cell: TaskCell)
}

class TaskCell: UITableViewCell {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var taskMarker: UIImageView!
    
    @IBOutlet weak var menuButton: UIImageView!
    
    var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        menuButton.isHidden = true
        configureCell()
    }
    
    func highlight() {
        switch taskMarker.isHighlighted {
        case false:
            taskMarker.isHighlighted = true
        default: 
            taskMarker.isHighlighted = false
        }
    }

    // tap action for marker button
    @objc func taskMarkerWasPressed(_ sender: UITapGestureRecognizer) {
        print(#function)
        highlight()
        // saving if a task marker was checked off - TodayVC
        delegate?.didTaskCell(self, change: taskMarker.isHighlighted)
    }
    
    // set up the cell
    func configureCell() {
        let taskMarkerAction = UITapGestureRecognizer(target: self, action: #selector(taskMarkerWasPressed(_:)))
        taskMarker.addGestureRecognizer(taskMarkerAction)
        taskMarker.isUserInteractionEnabled = true
        delegate?.updateTaskMarkers(self)
    }

}
