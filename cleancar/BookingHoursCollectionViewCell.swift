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
            self.addTopBorderWithColor(UIColor.yellowColor(), width: 2)
            self.addBottomBorderWithColor(UIColor.yellowColor(), width: 2)
            self.addLeftBorderWithColor(UIColor.yellowColor(), width: 2)
            self.addRightBorderWithColor(UIColor.yellowColor(), width: 2)
        } else {
            self.backgroundColor = UIColor.whiteColor()
            self.addTopBorderWithColor(UIColor.whiteColor(), width: 2)
            self.addBottomBorderWithColor(UIColor.whiteColor(), width: 2)
            self.addLeftBorderWithColor(UIColor.whiteColor(), width: 2)
            self.addRightBorderWithColor(UIColor.whiteColor(), width: 2)
        }
    }
}
