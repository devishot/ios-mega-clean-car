//
//  FeedbackTableViewCell.swift
//  cleancar
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class FeedbackTableViewCell: UITableViewCell {

    // outlets
    @IBOutlet weak var labelWasherName: UILabel!
    @IBOutlet weak var labelBookingHourTime: UILabel!
    @IBOutlet weak var labelTotalCost: UILabel!
    
    @IBOutlet weak var labelServicesDescription: UILabel!

    @IBOutlet weak var labelFeedbackMessage: UILabel!
    @IBOutlet weak var labelFeedbackRate: UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(feedback: Reservation) {
        labelWasherName.text = feedback.washer!.name
        labelBookingHourTime.text = feedback.bookingHour.getHour()
        labelTotalCost.text = formatMoney( feedback.services.getCostForTotal() )

        labelServicesDescription.text = feedback.services.getDescription()
        labelFeedbackMessage.text = feedback.feedbackMessage
        labelFeedbackRate.text = feedback.getFeedbackRateVisual()
    }

}
