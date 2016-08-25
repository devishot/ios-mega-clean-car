//
//  BookingController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/20/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase


class BookingController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var tableInsideContainerView: UIView!

    @IBOutlet weak var totalPriceLabel: UILabel!

    // IBActions
    @IBAction func changeCarButton(sender: UIButton) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sbPopUpID") as! PopUpViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMoveToParentViewController(self)
        
    }
    
    @IBAction func sendButton(sender: UIButton) {
    }

    // constants
    var embeddedTableViewControllerSegueID = "embeddedTableViewController"

    // variables
    var carInfo: CarInfo? {
        didSet {
            let selectedServices = self.servicesTableViewController!.selectedServices
            let updated = selectedServices.update(carInfo!.type)
            self.servicesTableViewController!.selectedServices = updated
        }
    }
    var bookingHour: BookingHour?
    var servicesTableViewController: ServicesTableViewController?


    override func viewDidLoad() {
        super.viewDidLoad()

        // set values
        timeLabel.text = self.bookingHour!.getHour()
        
        // set carInfo
        self.carInfo = CarInfo()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.hidden = true

        if self.carInfo != nil {
            self.carTypeLabel.text = self.carInfo?.getType()
            self.carNumberLabel.text = self.carInfo?.identifierNumber
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.embeddedTableViewControllerSegueID {
            let tableViewController = segue.destinationViewController as! ServicesTableViewController

            self.servicesTableViewController = tableViewController
            tableViewController.updateTotal = { totalCost in
                self.totalPriceLabel.text = totalCost
            }
        }
    }

}

