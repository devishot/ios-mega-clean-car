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
        let actionSheet = UIAlertController(title: nil,
                                            message: "Выберите действие",
                                            preferredStyle: .ActionSheet)

        let logOut = UIAlertAction(title: "Выйти", style: .Destructive,
                                   handler: { (alert: UIAlertAction!) -> Void in
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


    // IBOutlets
    @IBOutlet weak var roundedBorderView: UIView!

    @IBOutlet weak var timeOfOrderLabel: UILabel!
    @IBOutlet weak var nameOfCarLabel: UILabel!
    @IBOutlet weak var numberOfCarLabel: UILabel!

    @IBOutlet weak var chooseTimeCollectionView: UICollectionView!
    @IBOutlet weak var makeReservationButton: UIButton!

    
    // Identifiers
    var bookingHourCellID = "bookingHourCell"
    var bookingSegueID = "bookingSegue"


    // variables
    var bookingHours: [BookingHour] = []
    var bookingHoursSelectedIndex: NSIndexPath? {
        didSet {
            self.chooseTimeCollectionView.reloadData()

            if self.bookingHoursSelectedIndex != nil {
                self.makeReservationButton.enabled = true
            } else {
                self.makeReservationButton.enabled = false
            }
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
        roundedBorderView.layer.cornerRadius = 20
        roundedBorderView.layer.masksToBounds = true
        roundedBorderView.layer.borderWidth = 1
        roundedBorderView.layer.borderColor = UIColor.grayColor().CGColor


        // 2. Init behaviour
        chooseTimeCollectionView.dataSource = self
        chooseTimeCollectionView.delegate = self

        self.makeReservationButton.enabled = true


        // 3. Fetch data
        BookingHour.subscribeAndFetchData({ () -> (Void) in
            self.bookingHours = BookingHour.today
            self.chooseTimeCollectionView.reloadData()
        })
        Washer.fetchData(){}
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.hidden = false
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.bookingSegueID {
            let destinationController = segue.destinationViewController as! BookingController
            destinationController.bookingHour = self.bookingHours[self.bookingHoursSelectedIndex!.row]
        }
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
        let isSelected = self.bookingHoursSelectedIndex == indexPath
        cell.configure(isSelected)

        // Set data
        cell.bookingHour = self.bookingHours[indexPath.row]

        return cell
    }
    

}

extension HomeViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selected = self.bookingHoursSelectedIndex where selected == indexPath {
            self.bookingHoursSelectedIndex = nil
        } else {
            self.bookingHoursSelectedIndex = indexPath
        }
    }

}
