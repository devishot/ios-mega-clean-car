//
//  SignupSecondStepViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/15/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class SignupSecondStepViewController: UIViewController {

    // outlets
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBAction func changedTextFieldFullName(sender: UITextField) {
        let isEmpty = (sender.text?.characters.count == 0)
        self.buttonSave.enabled = !isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // styles
        buttonSave.layer.borderColor = UIColor.whiteColor().CGColor
        buttonSave.layer.borderWidth = 1
        buttonSave.layer.masksToBounds = true
        buttonSave.layer.cornerRadius = 5


        // init
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupSecondStepViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
