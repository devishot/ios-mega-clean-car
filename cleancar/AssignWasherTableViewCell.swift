//
//  AssignWasherTableViewCell.swift
//  cleancar
//
//  Created by MacBook Pro on 9/3/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class AssignWasherTableViewCell: UITableViewCell {
    
    // outlets
    @IBOutlet weak var nameLabel: UILabel!


    func configure(washer: Washer) {
        nameLabel.text = washer.name
    }
}
