//
//  FeedbackViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 20.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Cosmos


class FeedbackViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet var cosmosView: CosmosView!


    // IBActions
    @IBOutlet weak var sendFeedbackButton: UIButton!


    // constants
    let placeholder = "Спасибо, мне все понравилось"
    let placeholderColor = UIColor.grayColor()
    let nonPlaceholderColor = UIColor.blackColor()


    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundView.layer.masksToBounds = true
        backgroundView.layer.cornerRadius = 8
        
        sendFeedbackButton.layer.cornerRadius = 8
        sendFeedbackButton.layer.masksToBounds = true
        

        // navigationbar item color
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.orangeColor(),
            NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!
        ]
        self.navigationController!.navigationBar.tintColor = UIColor.orangeColor();
        self.navigationController!.navigationBar.backgroundColor = UIColor.whiteColor();
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
        
        
        // init
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)

        feedbackTextView.delegate = self
        self.showPlaceholder()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getRate() -> Int {
        return Int(self.cosmosView.rating)
    }

    func getMessage() -> String {
        return feedbackTextView.text
    }


    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
}


extension FeedbackViewController: UITextViewDelegate {

    func hidePlaceholder() {
        if self.feedbackTextView.textColor == placeholderColor {
            self.feedbackTextView.textColor = nonPlaceholderColor
            self.feedbackTextView.text = ""
        }
    }

    func showPlaceholder() {
        if self.feedbackTextView.text.characters.count == 0 {
            self.feedbackTextView.textColor = placeholderColor
            self.feedbackTextView.text = placeholder
        }
    }


    func textViewDidBeginEditing(textView: UITextView) {
        self.hidePlaceholder()
    }

    func textViewDidEndEditing(textView: UITextView) {
        self.showPlaceholder()
    }
}




