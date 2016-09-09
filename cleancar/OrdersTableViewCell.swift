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
    @IBOutlet weak var boxLabel: UILabel!
    @IBOutlet weak var numberOfBoxLabel: UILabel!
    
    @IBOutlet weak var cleanserLabel: UILabel!
    @IBOutlet weak var cleanserNameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var carModelName: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    
    @IBOutlet weak var overallPriceLabel: UILabel!
    
    @IBOutlet weak var servicesDescriptionLabel: UILabel!


    
    // variables
    var value: Reservation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(value: Reservation) {
        self.value = value

        let isAssigned = value.status.rawValue > ReservationStatus.NonAssigned.rawValue

        if isAssigned {
            numberOfBoxLabel.text = value.getBoxIndexText()
            cleanserNameLabel.text = value.washer!.name
        } else {
            numberOfBoxLabel.text = "?"
            cleanserNameLabel.text = "?"
        }
        timeLabel.text = value.bookingHour.getHour()
        overallPriceLabel.text = formatMoney(value.services.getCostForTotal())
        servicesDescriptionLabel.text = value.services.getDescription()
        if let carInfo = value.user.carInfo {
            carModelName.text = carInfo.model!
            carNumberLabel.text = carInfo.identifierNumber!
        }
    }

}
