//
//  HomeViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 17.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase


class HomeViewController: UIViewController {


    // IBActions
    @IBAction func goToMapButton(sender: UIButton) {
    }
    @IBAction func callButton(sender: UIButton) {
    }
    @IBAction func touchUpMakeReservationButton(sender: AnyObject) {
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
    
    // variables
    var bookingHours: [BookingHour] = []


    // UIViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        
        
        //rounded button
        makeReservationButton.layer.cornerRadius = 5
        makeReservationButton.layer.masksToBounds = true
       
        // rounded view
        roundedBorderView.layer.cornerRadius = 20
        roundedBorderView.layer.masksToBounds = true
        roundedBorderView.layer.borderWidth = 1
        roundedBorderView.layer.borderColor = UIColor.grayColor().CGColor
    

        chooseTimeCollectionView.dataSource = self

        BookingHour.subscribeToData({ (snapshot: FIRDataSnapshot) -> Void in
            let values = snapshot.value as! [AnyObject]

            for (index, value) in values.enumerate() {
                self.bookingHours.append( BookingHour(index: index, data: value) )
            }
            self.chooseTimeCollectionView.reloadData()
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
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
        cell.configure()

        // Set data
        cell.bookingHour = self.bookingHours[indexPath.row]

        print(indexPath.row, cell.bookingHour?.getHour())

        return cell
    }
}
