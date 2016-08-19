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
    func configure() -> Void {
        self.backgroundColor = UIColor.blackColor()
        self.hourLabel.textColor = UIColor.yellowColor()
    }
}
