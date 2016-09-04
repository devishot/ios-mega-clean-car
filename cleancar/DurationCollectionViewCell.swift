//
//  DurationCollectionViewCell.swift
//  cleancar
//
//  Created by Aigerim'sMac on 02.09.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class DurationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!


    func configure(index: Int, isSelected: Bool) {
        
        let minute = (index + 1) * Reservation.timeToWashMinuteMultiplier
        hourLabel.text = "\(minute)"

        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        if isSelected {
            self.layer.borderColor = UIColor.yellowColor().CGColor
        } else {
            self.layer.borderColor = UIColor.clearColor().CGColor
        }
    }

}
