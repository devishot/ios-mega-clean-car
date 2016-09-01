//
//  FeedbackViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 20.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!


    // IBActions
    @IBOutlet weak var sendFeedbackButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 8
        
        sendFeedbackButton.layer.cornerRadius = 8
        sendFeedbackButton.layer.masksToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




