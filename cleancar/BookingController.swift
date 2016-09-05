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
        let bookingHour = self.bookingHour!,
            carInfo = self.carInfo,
            services = self.servicesTableViewController!.selectedServices
        //print(".sendButton", bookingHour, carInfo, services)
        Reservation.create(carInfo, bookingHour: bookingHour, services: services) {
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
    var carInfo: CarInfo = CarInfo() {
        didSet {
            if self.isViewLoaded() {
                self.setDataByCarType()
            }
        }
    }
    var bookingHour: BookingHour?
    var servicesTableViewController: ServicesTableViewController?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let bottomInset = bottomLayoutGuide.length
        let bottomInset = self.tabBarController!.tabBar.bounds.height
        scrollView.contentInset.bottom = 3*bottomInset
        scrollView.scrollIndicatorInsets.bottom = -bottomInset
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
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

    func setDataByCarType() -> Void {
        // update servicesTableView
        let services = self.servicesTableViewController!.selectedServices,
        updated = services.update(carInfo.type)
        self.servicesTableViewController!.selectedServices = updated
        
        // update transform views
        if self.carInfo.isDefault() {
            self.hideCarDetailView()
        } else {
            self.showCarDetailView()
        }
    }

    func showCarDetailView() -> Void {
        UIView.transitionFromView(self.transitionViewNoCar,
                                  toView: self.transitionViewWithCar,
                                  duration: 0.2,
                                  options: UIViewAnimationOptions.ShowHideTransitionViews,
                                  completion: nil)

        carTypeLabel.text = self.carInfo.model
        carNumberLabel.text = self.carInfo.identifierNumber

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
}

