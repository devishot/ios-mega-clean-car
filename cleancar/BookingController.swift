//
//  BookingController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/20/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class BookingController: UIViewController, Dimmable {
    
    // IBOutlets
    @IBOutlet weak var transitionViewWithCar: UIView!
    
    @IBOutlet weak var transitionViewNoCar: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var changeCarButton: UIButton!
    @IBOutlet weak var tableInsideContainerView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!


    // IBActions
    @IBAction func sendButton(sender: UIButton) {
        let bookingHour = self.bookingHour!,
            carInfo = self.carInfo!,
            services = self.servicesTableViewController!.selectedServices
        print(".sendButton", bookingHour, carInfo, services)
        Reservation.create(carInfo, bookingHour: bookingHour, services: services) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    @IBAction func unwindFromPopupChangeCarInfo(segue: UIStoryboardSegue) {
        let popUpViewController = segue.sourceViewController as! PopUpViewController
        // get carInfo
        self.carInfo = popUpViewController.carInfo
        // animate
        dim(.Out, speed: dimSpeed)
    }


    // constants
    let embeddedTableViewControllerSegueID = "embeddedTableViewController"
    let popupChangeCarInfoSegueID = "popupChangeCarInfo"
    let addLabelText = "Добавить"
    let updateLabelText = "Изменить"
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5


    // variables
    var carInfo: CarInfo? {
        didSet {
            // update servicesTableView
            let selectedServices = self.servicesTableViewController!.selectedServices
            let updated = selectedServices.update(carInfo!.type)
            self.servicesTableViewController!.selectedServices = updated

            if self.carInfo!.model != nil {
                self.showCarDetailView()
            } else {
                self.hideCarDetailView()
            }
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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.embeddedTableViewControllerSegueID {
            let tableViewController = segue.destinationViewController as! ServicesTableViewController

            self.servicesTableViewController = tableViewController
            tableViewController.updateTotal = { totalCost in
                self.totalPriceLabel.text = formatMoney(totalCost)
            }
        }
        if segue.identifier == self.popupChangeCarInfoSegueID {
            let popUpViewController = segue.destinationViewController as! PopUpViewController
            // set carInfo
            popUpViewController.carInfo = self.carInfo
            // animate
            dim(.In, alpha: dimLevel, speed: dimSpeed)
        }
    }


    func showCarDetailView() -> Void {
        UIView.transitionFromView(self.transitionViewNoCar,
                                  toView: self.transitionViewWithCar,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)

        // set values
        carTypeLabel.text = self.carInfo!.model
        carNumberLabel.text = self.carInfo!.identifierNumber
        // update button
        changeCarButton.titleLabel?.text = updateLabelText
    }

    func hideCarDetailView() -> Void {
        UIView.transitionFromView(self.transitionViewWithCar,
                                  toView: self.transitionViewNoCar,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)

        // update button
        changeCarButton.titleLabel?.text = addLabelText
    }
}

