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
    @IBOutlet weak var carTypeImage: UIImageView!
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
            self.navigationController?.popViewControllerAnimated(true)
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
        [roundedSendButton, changeCarButton].forEach { button in
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
        }

        // set values
        timeLabel.text = self.bookingHour!.getHour()
        self.setDataByCarType()

    }
    override func viewWillAppear(animated: Bool) {
        self.extSetNavigationBarStyle(UIColor.ccPurpleDark())
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

        if let car = self.carInfo {
            carTypeImage.image = car.type.icon()
            carTypeLabel.text = car.model
            carNumberLabel.text = car.identifierNumber
        }
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

