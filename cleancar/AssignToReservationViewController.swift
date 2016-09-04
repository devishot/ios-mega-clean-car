//
//  SelectPropertiesViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 02.09.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class AssignToReservationViewController: UIViewController {

    //outlets
    @IBOutlet weak var durationCollectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!

 
    //actions
    @IBAction func sendButton(sender: UIButton) {
    }
    @IBAction func unwindAssignWasher(unwindSegue: UIStoryboardSegue) {
        let sourceController = unwindSegue.sourceViewController as! AssignWasherTableViewController
        self.valueWasher = sourceController.assignedWasher
    }
    @IBAction func unwindAssignBoxIndex(unwindSegue: UIStoryboardSegue) {
        let sourceController = unwindSegue.sourceViewController as! AssignBoxIndexTableViewController
        self.valueBoxIndex = sourceController.assignedBoxIndex
    }


    // identifiers
    let segueAssignWasherID = "assignWasher"
    let segueAssignBoxIndexID = "assignBoxIndex"
    let segueEmbeddedTableViewID = "embeddedTableView"
    let cellAssignBoxIndexID = "assignBoxIndexCell"
    let cellAssignWasherID = "assignWasherCell"


    // constants
    let textSelectBoxIndex = "Выберите номер бокса"
    let textSelectWasher = "Выберите мойщика"

    
    //variables
    var selectedIndex: Int?
    var embeddedTableView: UITableView?

    var bookingHour: BookingHour?
    var valueBoxIndex: Int? {
        didSet {
            self.embeddedTableView?.reloadData()
        }
    }
    var valueWasher: Washer? {
        didSet {
            self.embeddedTableView?.reloadData()
        }
    }
    var valueTimeToWash: Int?


    override func viewDidLoad() {
        super.viewDidLoad()

        // set styles
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = 5

        // init
        self.durationCollectionView.delegate = self
        self.durationCollectionView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueEmbeddedTableViewID {
            let destConroller = segue.destinationViewController as! UITableViewController
            self.embeddedTableView = destConroller.tableView
            self.embeddedTableView!.delegate = self
            self.embeddedTableView!.dataSource = self
        }

        if segue.identifier == segueAssignWasherID {
            let destController = segue.destinationViewController as! AssignWasherTableViewController

            let washers = Washer.all
                .filter({ (id, washer) in self.bookingHour!.washers[id] == true })
                .map({ $0.1 })

            destController.washers = washers
            destController.assignedWasher = self.valueWasher
        }

        if segue.identifier == segueAssignBoxIndexID {
            let destController = segue.destinationViewController as! AssignBoxIndexTableViewController

            let boxIndexes = self.bookingHour!.boxes
                .filter({ $0.boolValue })
                .map({ $0.hashValue })

            destController.boxIndexes = boxIndexes
            destController.assignedBoxIndex = self.valueBoxIndex
        }

    }

}


extension AssignToReservationViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(),
            cellText = ""

        if indexPath.row == 0 {
            cell = self.embeddedTableView!.dequeueReusableCellWithIdentifier(cellAssignBoxIndexID, forIndexPath: indexPath)
            cellText = (self.valueBoxIndex != nil) ? "Бокс: \(self.valueBoxIndex!)" : textSelectBoxIndex
        } else {
            cell = self.embeddedTableView!.dequeueReusableCellWithIdentifier(cellAssignWasherID, forIndexPath: indexPath)
            cellText = (self.valueWasher != nil) ? "Мойщик: \(self.valueWasher!.name)" : textSelectWasher
        }

        cell.textLabel!.text = cellText
        return cell
    }
}

extension AssignToReservationViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let segue: String = (indexPath.row == 0) ? segueAssignBoxIndexID : segueAssignWasherID
        self.performSegueWithIdentifier(segue, sender: self)
    }
}


extension AssignToReservationViewController: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("durationCell", forIndexPath: indexPath) as! DurationCollectionViewCell
        let isSelected = self.selectedIndex == indexPath.row

        cell.configure(indexPath.row, isSelected: isSelected)

        return cell
    }
}


extension AssignToReservationViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {

        self.selectedIndex = indexPath.row
        self.durationCollectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = nil
        self.durationCollectionView.reloadData()
    }
}


