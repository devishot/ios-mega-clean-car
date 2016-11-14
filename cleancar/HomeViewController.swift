//
//  HomeViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 17.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit


class HomeViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var viewInfo: UIView!


    // IBActions
    @IBAction func goToMapButton(sender: UIButton) {
    }
    @IBAction func callButton(sender: UIButton) {
        let phoneNumber = FirebaseRemoteConfig.value(.PhoneNumber).stringValue!
        let name = FirebaseRemoteConfig.value(.AdministatorName).stringValue!
        displayCallAlert(phoneNumber, displayText: "Администратору: \(name)", sender: self)
    }
    @IBAction func clickedMenuButton(sender: UIButton) {
        self.displayMenuView()
    }
    @IBAction func clickedCancelReservation(sender: UIButton) {
        displayPromptView("Хотите отменить бронь?", self: self) { (value: Bool) -> Void in
            if value {
                self.currentUser!.currentReservation!.setDeclined(){}
            }
        }
    }
    @IBAction func clickedRateReservation(sender: UIButton) {
        performSegueWithIdentifier(segueRateID, sender: self)
    }

    @IBAction func unwindRate(unwindSegue: UIStoryboardSegue) {
        let sourceController = unwindSegue.sourceViewController as! FeedbackViewController
        let rate = sourceController.getRate(),
            message = sourceController.getMessage()

        let reservation = self.currentUser!.currentReservation!
        reservation.setFeedbackReceived(rate, message: message) {}
    }

    
    // IBOutlets
    @IBOutlet weak var noReservationView: UIView!
    @IBOutlet weak var ReservationView: UIView!

    @IBOutlet weak var labelReservationTime: UILabel!
    @IBOutlet weak var labelReservationCost: UILabel!
    @IBOutlet weak var labelReservationCarInfoNumber: UILabel!
    @IBOutlet weak var labelReservationServices: UILabel!

    @IBOutlet weak var scrollviewReservationInfo: UIScrollView!
    @IBOutlet weak var pagecontrollReservationInfo: UIPageControl!
    @IBOutlet weak var constraintsLeadingOfReservationInfoSecondView: NSLayoutConstraint!
    @IBOutlet weak var viewReservationInfoFirstView: UIView!

    @IBOutlet weak var chooseTimeCollectionView: UICollectionView!
    @IBOutlet weak var buttonMakeReservation: UIButton!
    @IBOutlet weak var buttonCall: UIButton!
    
    @IBOutlet weak var buttonMap: UIButton!
    @IBOutlet weak var buttonReservationCancel: UIButton!
    @IBOutlet weak var buttonReservationRate: UIButton!
    
    @IBOutlet weak var labelAddressName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelTimeRange: UILabel!
    


    // Identifiers
    var bookingHourCellID = "bookingHourCell"
    var bookingSegueID = "bookingSegue"
    var segueRateID = "rate"

    // variables
    var currentUser: User?
    var bookingHours: [BookingHour] = []
    var bookingHoursSelectedIndex: NSIndexPath? {
        didSet {
            self.chooseTimeCollectionView.reloadData()

            if bookingHoursSelectedIndex != nil {
                self.buttonMakeReservation.enabled = true
            } else {
                self.buttonMakeReservation.enabled = false
            }
        }
    }


    // UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Init styles
        self.tabBarController!.tabBar.translucent = false

        [buttonMakeReservation, buttonReservationCancel, buttonReservationRate, buttonMap, buttonCall].forEach { button in
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.masksToBounds = false
            button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
            button.layoutIfNeeded()
        }
        
        labelAddressName.text = FirebaseRemoteConfig.value(.AddressNameLabel).stringValue
        labelAddress.text = FirebaseRemoteConfig.value(.AddressLabel).stringValue
        labelTimeRange.text = FirebaseRemoteConfig.value(.TimeRangeLabel).stringValue

        // 2. Init behaviour
        scrollviewReservationInfo.delegate = self
        chooseTimeCollectionView.dataSource = self
        chooseTimeCollectionView.delegate = self

        // 3. Subscribe to data
        BookingHour.subscribeToToday({ () -> (Void) in
            self.bookingHours = BookingHour.fromNow
            self.chooseTimeCollectionView.reloadData()
        })
        User.subscribeToCurrent({ userError in
            self.currentUser = User.current
            self.updateCurrentReservationView()
        })

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(".HomeVC viewWillAppear")

        setStatusBarBackgroundColor(UIColor.ccPurpleDark())
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if self.currentUser != nil {
            self.updateCurrentReservationView()
        }
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print(".HomeVC viewDidDisappear")

        self.bookingHoursSelectedIndex = nil

        BookingHour.unsubscribe()
        User.unsubscribe()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.bookingSegueID {
            let destinationController = segue.destinationViewController as! BookingController
            destinationController.bookingHour = self.bookingHours[self.bookingHoursSelectedIndex!.row]
            if let carInfo = self.currentUser!.carInfo {
                destinationController.carInfo = carInfo
            }
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
    }


    func updateCurrentReservationView() {
        let user = self.currentUser!

        if  let reservation: Reservation = user.currentReservation,
            let carInfo: CarInfo = reservation.user.carInfo {

            self.labelReservationTime.text = reservation.bookingHour.getHour()
            self.labelReservationCost.text = formatMoney(reservation.services.getCostForTotal())
            self.labelReservationCarInfoNumber.text = carInfo.identifierNumber!
            self.labelReservationServices.text = "Выбранные услуги: \n" + reservation.services.getDescription()
            self.labelReservationServices.adjustsFontSizeToFitWidth = true

            // 1 swap
            UIView.transitionFromView(noReservationView, toView: ReservationView, duration: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            self.buttonMakeReservation.enabled = false
            self.chooseTimeCollectionView.allowsSelection = false
            // 2 hide
            UIView.transitionWithView(viewReservationInfoFirstView, duration: 0,
                                      options: UIViewAnimationOptions.ShowHideTransitionViews,
                                      animations: {
                                        self.viewReservationInfoFirstView.hidden = !reservation.isCompleted()
                                    }, completion: nil)
            // 3 swap
            if reservation.isCompleted() {
                UIView.transitionFromView(buttonReservationCancel, toView: buttonReservationRate, duration: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
                self.constraintsLeadingOfReservationInfoSecondView.priority = 251
                self.pagecontrollReservationInfo.numberOfPages = 3
            } else {
                UIView.transitionFromView(buttonReservationRate, toView: buttonReservationCancel, duration: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
                self.constraintsLeadingOfReservationInfoSecondView.priority = 999
                self.pagecontrollReservationInfo.numberOfPages = 2
            }

        } else {
            // swap
            UIView.transitionFromView(ReservationView, toView: noReservationView, duration: 0.2, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            self.chooseTimeCollectionView.allowsSelection = true
            self.constraintsLeadingOfReservationInfoSecondView.priority = 999
        }
    }

    func displayMenuView() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let logOut = UIAlertAction(title: "Выйти", style: .Destructive, handler: { (alert: UIAlertAction!) -> Void in

            // logout from firebase and facebook
            User.logOut()
            // redirect to LoginViewController
            let firstNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("loginNavController") as! UINavigationController
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(firstNavigationController, animated: true, completion: nil)
            })
        })
        let cancel = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)

        actionSheet.addAction(logOut)
        actionSheet.addAction(cancel)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}


extension HomeViewController : UICollectionViewDataSource {

    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    //2
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookingHours.count
    }

    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(bookingHourCellID, forIndexPath: indexPath) as! BookingHoursCollectionViewCell

        // Configure the cell
        let isSelected: Bool = self.bookingHoursSelectedIndex == indexPath
        let bookingHour = self.bookingHours[indexPath.row]
        cell.configure(isSelected, bookingHour: bookingHour)

        return cell
    }

}



extension HomeViewController : UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if !self.bookingHours[indexPath.row].isFree() {
            return
        }

        if let selected = self.bookingHoursSelectedIndex where selected == indexPath {
            self.bookingHoursSelectedIndex = nil
        } else {
            self.bookingHoursSelectedIndex = indexPath
        }
    }

}


extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let t = CGFloat(scrollView.contentSize.width / CGFloat(self.pagecontrollReservationInfo.numberOfPages))
        let page = Int(scrollView.contentOffset.x / t)
        self.pagecontrollReservationInfo.currentPage = page
    }

}


