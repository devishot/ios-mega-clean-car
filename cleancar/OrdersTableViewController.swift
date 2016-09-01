//
//  OrdersTableViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 23.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class OrdersTableViewController: UITableViewController {

    // IBOutlets
    @IBOutlet weak var filterButton: UIBarButtonItem!


    // IBActions
    @IBAction func clickedFilterButton(sender: UIBarButtonItem) {
        self.filterValue = (self.filterValue + 1) % 2

        self.updateFilterLabels()
    }


    // constants
    let filterNames = ["Все", "Отмененные"]
    let sections = [
        ["Новые", "Назначенные"],
        ["Отмененные"]
    ]


    // variables
    var nonAssigned: [Reservation] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var assigned: [Reservation] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var declined: [Reservation] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var filterValue: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // 2. load data
        Reservation.subscribeTo(ReservationStatus.NonAssigned, completion: { (reservations) in
            self.nonAssigned = reservations
        })
        Reservation.subscribeTo(ReservationStatus.Assigned, completion: { (reservations) in
            self.assigned = reservations
        })
        Reservation.subscribeTo(ReservationStatus.Declined, completion: { (reservations) in
            self.assigned = reservations
        })
    }

    override func viewDidDisappear(animated: Bool) {
        Reservation.unsubscribe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[filterValue][section]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getReservationsFor(section).count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("orderCellID", forIndexPath: indexPath) as! OrdersTableViewCell
    
        let reservation = self.getReservationsFor(indexPath.section)[indexPath.row]
        cell.configure(reservation)

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func getReservationsFor(section: Int) -> [Reservation] {
        if self.filterValue == 0 {
            return [self.nonAssigned, self.assigned][section]
        } else {
            return self.declined
        }
    }

    func updateFilterLabels() {
        self.navigationItem.title = self.filterButton.title
        self.filterButton.title = self.filterNames[self.filterValue]
    }
}
