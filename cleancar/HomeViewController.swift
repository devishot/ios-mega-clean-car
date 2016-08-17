//
//  HomeViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 17.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBAction func goToMapButton(sender: UIButton) {
    }
    
    
    @IBAction func callButton(sender: UIButton) {
    }
    
    
    @IBOutlet weak var roundedBorderView: UIView!
    
    @IBOutlet weak var timeOfOrderLabel: UILabel!
    @IBOutlet weak var nameOfCarLabel: UILabel!
    @IBOutlet weak var numberOfCarLabel: UILabel!
    
    @IBAction func cancelButton(sender: UIButton) {
    }
    
    @IBOutlet weak var chooseTimeCollectionView: UICollectionView!
    
    
    @IBAction func makeReservationButton(sender: UIButton) {
    }
    
    @IBOutlet weak var makeReservationChangeStyleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //rounded button
        makeReservationChangeStyleButton.layer.cornerRadius = 20
        makeReservationChangeStyleButton.layer.masksToBounds = true
       
        // rounded view
        roundedBorderView.layer.cornerRadius = 20
        roundedBorderView.layer.masksToBounds = true
        roundedBorderView.layer.borderWidth = 1
        roundedBorderView.layer.borderColor = UIColor.grayColor().CGColor

        // Do any additional setup after loading the view.
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
