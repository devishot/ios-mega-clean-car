//
//  FeedbackViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 20.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    
    //outlets
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!
    

    //actions
    @IBOutlet weak var sendFeedbackButton: UIButton!
    
    
    @IBOutlet weak var lineView1: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 8
        
        sendFeedbackButton.layer.cornerRadius = 8
        sendFeedbackButton.layer.masksToBounds = true
        
      
        
    

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




