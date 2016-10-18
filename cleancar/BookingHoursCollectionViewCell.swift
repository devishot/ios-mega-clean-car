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
    var bookingHour: BookingHour!

    // methods
    func configure(isSelected: Bool, bookingHour: BookingHour) -> Void {
        // style
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1

        if isSelected {
            self.layer.borderColor = UIColor.ccPurpleLight().CGColor
            self.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.hourLabel.textColor = UIColor.ccPurpleLight()
            self.statusLabel.textColor =  UIColor.ccPurpleLight()

        } else if bookingHour.isFree() {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.backgroundColor = UIColor.clearColor().CGColor
            self.hourLabel.textColor = UIColor.ccTextColorWhite()
            self.statusLabel.textColor = UIColor.ccTextColorGrayLight()

        } else {
            self.layer.borderColor = UIColor.whiteColor().CGColor
            self.layer.backgroundColor = UIColor.clearColor().CGColor
            self.hourLabel.textColor = UIColor.ccTextColorGray()
            self.statusLabel.textColor =  UIColor.ccTextColorGray()
        }

        // data
        self.bookingHour = bookingHour
        self.hourLabel.text = bookingHour.getHour()
        self.statusLabel.text = bookingHour.getStatus()
    }
}
