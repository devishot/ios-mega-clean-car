//
//  BookingHoursCollectionViewCell.swift
//  cleancar
//
//  Created by MacBook Pro on 8/19/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class BookingHoursCollectionViewCell: UICollectionViewCell {

    // IBActions
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // variables
    var bookingHour: BookingHour? {
        didSet {
            self.hourLabel.text = bookingHour!.getHour()
            self.statusLabel.text = bookingHour!.getStatus()

            if bookingHour!.isFree() {
                self.statusLabel.textColor = UIColor.greenColor()
            } else {
                self.statusLabel.textColor = UIColor.redColor()
            }
        }
    }

    // methods
    func configure(isSelected: Bool) -> Void {
        self.backgroundColor = UIColor.blackColor()
        self.hourLabel.textColor = UIColor.blackColor()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true

        if isSelected {
            self.layer.cornerRadius = 10
            self.layer.masksToBounds = true
            self.backgroundColor = UIColor.whiteColor()
            self.layer.borderColor = UIColor.yellowColor().CGColor
            self.layer.borderWidth = 2
            
        } else {
            self.layer.cornerRadius = 10
            self.layer.masksToBounds = true
            self.backgroundColor = UIColor.whiteColor()
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.borderWidth = 2
        
        }
    }
}
