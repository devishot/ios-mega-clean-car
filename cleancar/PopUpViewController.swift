//
//  PopUpViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 22.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!

    
    @IBOutlet weak var carNumberTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!

    
    @IBOutlet weak var lineOfNumberLabelView: UIView!
    @IBOutlet weak var lineOfModelLabelView: UIView!
    
    let carcasTypes = CarInfo.carTypeNames


    override func viewDidLoad() {
        super.viewDidLoad()
        //textfield customization
        lineOfNumberLabelView.addTopBorderWithColor(UIColor.lightGrayColor(), width: 1)
        lineOfModelLabelView.addTopBorderWithColor(UIColor.lightGrayColor(), width: 1)

        
        //view customization
        popUpView.layer.cornerRadius = 15
        popUpView.layer.masksToBounds = true
        popUpView.layer.backgroundColor = UIColor.whiteColor().CGColor
        

        //popup menu features
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return carcasTypes.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return carcasTypes[row]
    }

}
