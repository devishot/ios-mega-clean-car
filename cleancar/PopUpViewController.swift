//
//  PopUpViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 22.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var carNumberTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!

    @IBOutlet weak var lineOfNumberLabelView: UIView!
    @IBOutlet weak var lineOfModelLabelView: UIView!
    
    @IBOutlet weak var pickerView: UIPickerView!


    // IBActions
    @IBAction func clickedSaveButton(sender: UIButton) {
        if let carNumber = carNumberTextField.text,
           let carModel = carModelTextField.text {

            self.carInfo = CarInfo(type: self.selectedCarType, model: carModel, identifierNumber: carNumber)
        }
    }
    

    // variables
    let carTypes = CarInfo.carTypeNames
    var selectedCarType: CarTypeEnum = .Normal
    var carInfo: CarInfo? {
        didSet {
            if carInfo != nil {
                selectedCarType = carInfo!.type
            }
        }
    }


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

        // set values
        carNumberTextField.text = self.carInfo!.identifierNumber
        carModelTextField.text = self.carInfo!.model
        pickerView.selectRow(self.selectedCarType.rawValue, inComponent: 0, animated: false)

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}


extension PopUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.carTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.carTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCarType = CarTypeEnum(rawValue: row)!
    }
}



