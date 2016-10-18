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
    @IBOutlet weak var minuteStaticLabel: UILabel!


    func configure(index: Int, isSelected: Bool) {
        
        let minute = (index + 1) * Reservation.timeToWashMinuteMultiplier
        hourLabel.text = "\(minute)"

        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2

        if isSelected {
            self.layer.borderColor = UIColor.ccPurpleLight().CGColor
            self.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.hourLabel.textColor = UIColor.ccPurpleLight()
            self.minuteStaticLabel.textColor =  UIColor.ccPurpleLight()

        } else {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.backgroundColor = UIColor.clearColor().CGColor
            self.hourLabel.textColor = UIColor.ccTextColorWhite()
            self.minuteStaticLabel.textColor =  UIColor.ccTextColorGrayLight()
        }
    }

}
