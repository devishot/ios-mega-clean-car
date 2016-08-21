//
//  OrdersTableViewCell.swift
//  cleancar
//
//  Created by Aigerim'sMac on 20.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {
    //outlets
    @IBOutlet weak var boxNumberLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cleanserNameLabel: UILabel!
    
    @IBOutlet weak var carBrandLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    
    @IBOutlet weak var overallPriceLabel: UILabel!
    
    
    @IBOutlet weak var allSelectedServicesTextView: UITextView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
