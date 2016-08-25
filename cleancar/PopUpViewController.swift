//
//  PopUpViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 22.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var chooseCarCarcasTextField: UITextField!
    
    @IBOutlet weak var carNumberTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    @IBOutlet weak var carCarcasTextField: UITextField!
    
    
    @IBOutlet weak var lineOfNumberLabelView: UIView!
    @IBOutlet weak var lineOfModelLabelView: UIView!
    @IBOutlet weak var lineOfCarcasLabelView: UIView!
    
    let carcasTypes = CarInfo.carTypeNames
    var picker = UIPickerView()


    override func viewDidLoad() {
        super.viewDidLoad()
        //textfield customization
        lineOfNumberLabelView.addTopBorderWithColor(UIColor.lightGrayColor(), width: 1)
        lineOfModelLabelView.addTopBorderWithColor(UIColor.lightGrayColor(), width: 1)
        lineOfCarcasLabelView.addTopBorderWithColor(UIColor.lightGrayColor(), width: 1)
        
        //view customization
        popUpView.layer.cornerRadius = 15
        popUpView.layer.masksToBounds = true
        popUpView.layer.backgroundColor = UIColor.whiteColor().CGColor
        //piker view 
        picker.delegate = self
        picker.dataSource = self
        chooseCarCarcasTextField.inputView = picker

        //popup menu features
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //picker view functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return carcasTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chooseCarCarcasTextField.text = carcasTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return carcasTypes[row]
    }

}
