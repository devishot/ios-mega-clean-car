//
//  StatisticItemCell.swift
//  cleancar
//
//  Created by MacBook Pro on 9/13/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class StatisticItemCell: UICollectionViewCell {

    @IBOutlet weak var labelDescription: UILabel!

    override func awakeFromNib() {
        labelDescription.adjustsFontSizeToFitWidth = true
        labelDescription.sizeToFit()
    }
}
