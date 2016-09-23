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

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var transitionViewWithCar: UIView!
    @IBOutlet weak var transitionViewNoCar: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var changeCarButton: UIButton!
    @IBOutlet weak var tableInsideContainerView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var roundedSendButton: UIButton!


    // IBActions
    @IBAction func sendButton(sender: UIButton) {
        let bookingHour = self.bookingHour,
            carInfo = self.carInfo,
            services = self.servicesTableViewController!.selectedServices
        
        if carInfo == nil {
            self.displayAlertNoCar()
            return
        }

        Reservation.create(carInfo!, bookingHour: bookingHour!, services: services) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    @IBAction func unwindFromPopupChangeCarInfo(segue: UIStoryboardSegue) {
        let popUpViewController = segue.sourceViewController as! PopUpViewController
        // get carInfo
        self.carInfo = popUpViewController.carInfo!
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
            if self.isViewLoaded() {
                self.setDataByCarType()
            }
        }
    }
    var bookingHour: BookingHour?
    var servicesTableViewController: ServicesTableViewController?


    override func viewDidLoad() {
        super.viewDidLoad()

        // init styles
        roundedSendButton.layer.cornerRadius = 5
        roundedSendButton.layer.masksToBounds = true

        // set values
        timeLabel.text = self.bookingHour!.getHour()
        self.setDataByCarType()

        // navigationbar item color
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.orangeColor(),
            NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!
        ]
        self.navigationController!.navigationBar.tintColor = UIColor.orangeColor();
        self.navigationController!.navigationBar.backgroundColor = UIColor.whiteColor();
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
       
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let bottomInset = self.tabBarController?.tabBar.bounds.height {
            scrollView.contentInset.bottom = 2*bottomInset
            scrollView.scrollIndicatorInsets.bottom = -bottomInset
        }
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
            if self.carInfo == nil {
                popUpViewController.carInfo = CarInfo()
            } else {
                popUpViewController.carInfo = self.carInfo
            }

            // animate
            dim(.In, alpha: dimLevel, speed: dimSpeed)
        }
    }

    func setDataByCarType() -> Void {
        var carType: CarTypeEnum = .Normal
        if self.carInfo != nil {
            carType = self.carInfo!.type
            self.showCarDetailView()
        } else {
            self.hideCarDetailView()
        }

        // update servicesTableView
        let services = self.servicesTableViewController!.selectedServices,
        updated = services.update(carType)
        self.servicesTableViewController!.selectedServices = updated
    }

    func showCarDetailView() -> Void {
        UIView.transitionFromView(self.transitionViewNoCar,
                                  toView: self.transitionViewWithCar,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)

        carTypeLabel.text = self.carInfo!.model
        carNumberLabel.text = self.carInfo!.identifierNumber

        changeCarButton.titleLabel!.text = updateLabelText
    }

    func hideCarDetailView() -> Void {
        UIView.transitionFromView(self.transitionViewWithCar,
                                  toView: self.transitionViewNoCar,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)
        changeCarButton.titleLabel!.text = addLabelText
    }
    
    
    func displayAlertNoCar() {
        let title = "Пожалуйста, укажите автомобиль"
        let alert = UIAlertController(title: nil, message: title, preferredStyle: .Alert)

        let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancel)

        self.presentViewController(alert, animated: true, completion: nil)

    }
}

