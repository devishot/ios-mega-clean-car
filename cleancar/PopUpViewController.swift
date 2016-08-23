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
    
    var carcasTypes = ["Седан","Кроссовер","Внедорожник","Микроавтобус"]
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
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        self.showAnimate()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closePopUpButton(sender: UIButton) {
    
     self.removeAnimate()
    
    }
    
    //animates popup menu
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
