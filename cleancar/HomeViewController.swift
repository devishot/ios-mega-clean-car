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


    // IBActions
    @IBAction func goToMapButton(sender: UIButton) {
    }
    @IBAction func callButton(sender: UIButton) {
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
    @IBOutlet weak var roundedBorderView: UIView!
    @IBOutlet weak var noReservationView: UIView!
    @IBOutlet weak var viewReservationRate: UIView!
    @IBOutlet weak var viewReservationCancel: UIView!
    @IBOutlet weak var timeOfOrderLabel: UILabel!
    @IBOutlet weak var nameOfCarLabel: UILabel!
    @IBOutlet weak var numberOfCarLabel: UILabel!

    @IBOutlet weak var chooseTimeCollectionView: UICollectionView!
    @IBOutlet weak var makeReservationButton: UIButton!


    // Identifiers
    var bookingHourCellID = "bookingHourCell"
    var bookingSegueID = "bookingSegue"
    var segueRateID = "rate"


    // variables
    var bookingHours: [BookingHour] = []
    var bookingHoursSelectedIndex: NSIndexPath? {
        didSet {
            self.chooseTimeCollectionView.reloadData()

            if bookingHoursSelectedIndex != nil {
                self.makeReservationButton.enabled = true
            } else {
                self.makeReservationButton.enabled = false
            }
        }
    }
    var currentUser: User? {
        didSet {
            self.updateCurrentReservationView()
        }
    }


    // UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Init styles

            //rounded button
        makeReservationButton.layer.cornerRadius = 5
        makeReservationButton.layer.masksToBounds = true

            // rounded view
        roundedBorderView.layer.cornerRadius = 10
        roundedBorderView.layer.masksToBounds = true
        roundedBorderView.layer.borderWidth = 1
        roundedBorderView.layer.borderColor = UIColor.orangeColor().CGColor


        // 2. Init behaviour
        chooseTimeCollectionView.dataSource = self
        chooseTimeCollectionView.delegate = self


        // 3. Fetch data
        Washer.fetchData() {
            BookingHour.subscribeToToday({ () -> (Void) in
                self.bookingHours = BookingHour.today
                self.chooseTimeCollectionView.reloadData()
            })
            User.subscribeToCurrent({ () -> (Void) in
                self.currentUser = User.current
            })
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.hidden = false

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
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
    }


    func updateCurrentReservationView() {
        let user = self.currentUser!

        if  let reservation: Reservation = user.currentReservation,
            let carInfo: CarInfo = reservation.user.carInfo {

            self.timeOfOrderLabel.text = reservation.bookingHour.getHour()
            self.nameOfCarLabel.text = carInfo.model!
            self.numberOfCarLabel.text = carInfo.identifierNumber!

            if reservation.isCompleted() {
                UIView.transitionFromView(
                    viewReservationCancel,
                    toView: viewReservationRate,
                    duration: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
            } else {
                if reservation.isCompleted() {
                    UIView.transitionFromView(
                        viewReservationRate,
                        toView: viewReservationCancel,
                        duration: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
                }
            }

            UIView.transitionFromView(noReservationView, toView: roundedBorderView, duration: 0.2, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
        } else {
            UIView.transitionFromView(roundedBorderView, toView: noReservationView, duration: 0.2, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
        }
    }

    func displayMenuView() {
        let actionSheet = UIAlertController(title: nil,
                                            message: "Выберите действие",
                                            preferredStyle: .ActionSheet)
        
        let logOut = UIAlertAction(title: "Выйти", style: .Destructive, handler: { (alert: UIAlertAction!) -> Void in

            // logout from firebase and facebook
            User.logOut() {
                // redirect to LoginViewController
                let firstNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("loginNavController") as! UINavigationController
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(firstNavigationController, animated: true, completion: nil)
                    return
                })
            }
        })
        
        let cancel = UIAlertAction(title: "Отмена", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
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
        cell.configure(isSelected)

        // Set data
        cell.bookingHour = self.bookingHours[indexPath.row]

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
