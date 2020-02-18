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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        switch self.isSelected {
        case true:
            if taskMarker.isHighlighted == true {
                taskMarker.isHighlighted = true
            } else {
                taskMarker.isHighlighted = false
            }
        case false:
            if taskMarker.isHighlighted == false {
                taskMarker.isHighlighted = false
            } else {
                taskMarker.isHighlighted = true
            }
            
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
    }

}
