//
//  GoalCell.swift
//  FocusOn
//
//  Created by Matthew Sousa on 12/4/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var taskMarker: UIImageView!
    
    @IBOutlet weak var menuButton: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        menuButton.isHidden = true
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
        
    }

}
