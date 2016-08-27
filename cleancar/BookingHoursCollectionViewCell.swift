//
//  BookingHoursCollectionViewCell.swift
//  cleancar
//
//  Created by MacBook Pro on 8/19/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class BookingHoursCollectionViewCell: UICollectionViewCell {
    
    // IBOutlets
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // variables
    var bookingHour: BookingHour? {
        didSet {
            hourLabel.text = bookingHour!.getHour()
        }
    }

    // methods
    func configure(isSelected: Bool) -> Void {
        self.backgroundColor = UIColor.blackColor()
        self.hourLabel.textColor = UIColor.blackColor()

        if isSelected {
            self.backgroundColor = UIColor.whiteColor()
            self.addTopBorderWithColor(UIColor.yellowColor(), width: 5)
            self.addBottomBorderWithColor(UIColor.yellowColor(), width: 5)
            self.addLeftBorderWithColor(UIColor.yellowColor(), width: 5)
            self.addRightBorderWithColor(UIColor.yellowColor(), width: 5)
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.addTopBorderWithColor(UIColor.whiteColor(), width: 5)
            self.addBottomBorderWithColor(UIColor.whiteColor(), width: 5)
            self.addLeftBorderWithColor(UIColor.whiteColor(), width: 5)
            self.addRightBorderWithColor(UIColor.whiteColor(), width: 5)
        }
    }
}
