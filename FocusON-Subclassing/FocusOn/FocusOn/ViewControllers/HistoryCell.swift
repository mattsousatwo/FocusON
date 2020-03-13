//
//  HistoryCell.swift
//  FocusOn
//
//  Created by Matthew Sousa on 3/2/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var taskMarker: UIImageView!
    
    @IBOutlet weak var menuButton: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
