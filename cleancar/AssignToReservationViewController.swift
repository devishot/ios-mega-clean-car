//
//  SelectPropertiesViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 02.09.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


enum SelectTableSources: Int {
    case AssignBoxIndex
    case AssignWasher
}


class AssignToReservationViewController: UIViewController {

    //outlets
    @IBOutlet weak var durationCollectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!


    //actions
    @IBAction func unwindSelectTableViewController(unwindSegue: UIStoryboardSegue) {
        let sourceController = unwindSegue.sourceViewController as! SelectTableViewController

        switch sourceController.sourceType! {
        case .AssignBoxIndex:
            self.valueBoxIndex = self.availableBoxIndexes[sourceController.selectedIndex!]
        case .AssignWasher:
            self.valueWasher = self.availableWashers[sourceController.selectedIndex!]
        }
    }


    // identifiers
    let segueSelectTableID = "selectTable"
    let segueAssignActionsTableID = "embeddedAssignActionsTable"
    let cellOfAssignActionsTableID = "assignActionCell"
    let cellDurationID = "durationCell"

    // constants
    let textSelectBoxIndex = "Выберите номер бокса"
    let textSelectWasher = "Выберите мойщика"

    //variables
    var embeddedTableView: UITableView?

    var bookingHour: BookingHour!
    var valueBoxIndex: Int? {
        didSet {
            self.embeddedTableView?.reloadData()
            self.updateSubmitButtonStyle()
        }
    }
    var valueWasher: Washer? {
        didSet {
            self.embeddedTableView?.reloadData()
            self.updateSubmitButtonStyle()
        }
    }
    var valueTimeToWash: Int? {
        didSet {
            self.updateSubmitButtonStyle()
        }
    }

    // calculate
    var availableWashers: [Washer]!
    var availableBoxIndexes: [Int]!


    override func viewDidLoad() {
        super.viewDidLoad()

        // set styles
        submitButton.layer.masksToBounds = true
        submitButton.layer.cornerRadius = 5
        self.updateSubmitButtonStyle()


        // init
        self.durationCollectionView.delegate = self
        self.durationCollectionView.dataSource = self


        // init variables
        availableWashers = Washer.all
            .filter({ (id, washer) in
                bookingHour.washers[id] == true
            })
            .map({ $0.1 })
        availableBoxIndexes = self.bookingHour.boxes
            .enumerate()
            .filter({ $0.element.boolValue })
            .map({ $0.index })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // init embedded tableview
        if segue.identifier == segueAssignActionsTableID {
            let destConroller = segue.destinationViewController as! UITableViewController
            self.embeddedTableView = destConroller.tableView
            self.embeddedTableView!.delegate = self
            self.embeddedTableView!.dataSource = self

        } else {
            let sourceType = SelectTableSources(rawValue: sender as! Int)!
            let destController = segue.destinationViewController as! SelectTableViewController
            destController.sourceType = sourceType

            switch sourceType {
            case .AssignWasher:
                destController.items = availableWashers.map({ $0.name })

                if self.valueWasher != nil {
                    let selectedItem = self.valueWasher!.name
                    destController.items.insert(selectedItem, atIndex: 0)
                    destController.selectedIndex = 0
                }

            case .AssignBoxIndex:
                destController.items = availableBoxIndexes.map({ "#\($0+1)" })

                if self.valueBoxIndex != nil {
                    let selectedItem = "#\(self.valueBoxIndex!+1)"
                    destController.items.insert(selectedItem, atIndex: 0)
                    destController.selectedIndex = 0
                }
            }
        }

    }

    func updateSubmitButtonStyle() {
        if !self.isViewLoaded() {
            return
        }
        var isActive = false
        if  let _ = self.valueWasher,
            let _ = self.valueBoxIndex,
            let _ = self.valueTimeToWash {
            isActive = true
        }
        self.submitButton.enabled = isActive
    }

}


// set labels for embedded tableview's cells
extension AssignToReservationViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.embeddedTableView?.dequeueReusableCellWithIdentifier(cellOfAssignActionsTableID, forIndexPath: indexPath)
        var cellText: String!
        
        let sourceType = SelectTableSources(rawValue: indexPath.row)!
        switch sourceType {
        case .AssignWasher:
            cellText = (self.valueWasher != nil) ? "Мойщик: \(self.valueWasher!.name)" : textSelectWasher
        case .AssignBoxIndex:
            cellText = (self.valueBoxIndex != nil) ? "Бокс: #\(self.valueBoxIndex!+1)" : textSelectBoxIndex
        }

        print(".tableView.cellForRow", indexPath.row, cellText)
        
        cell!.textLabel!.text = cellText
        return cell!
    }
}

// redirect on click tableview's cells
extension AssignToReservationViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(segueSelectTableID, sender: indexPath.row)
    }
}


// configure duration cells
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellDurationID, forIndexPath: indexPath) as! DurationCollectionViewCell
        let isSelected = self.valueTimeToWash == indexPath.row

        cell.configure(indexPath.row, isSelected: isSelected)

        return cell
    }
}

// update duration cells on select
extension AssignToReservationViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView,
                        didSelectItemAtIndexPath indexPath: NSIndexPath) {

        self.valueTimeToWash = indexPath.row
        self.durationCollectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.valueTimeToWash = nil
        self.durationCollectionView.reloadData()
    }
}


