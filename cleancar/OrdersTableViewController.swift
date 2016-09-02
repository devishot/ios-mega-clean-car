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

        // 2. load data
        BookingHour.subscribeToToday({ () -> (Void) in

            Reservation.subscribeTo(ReservationStatus.NonAssigned, completion: { (reservations) in
                self.nonAssigned = reservations
            })
            Reservation.subscribeTo(ReservationStatus.Assigned, completion: { (reservations) in
                self.assigned = reservations
            })
            Reservation.subscribeTo(ReservationStatus.Declined, completion: { (reservations) in
                self.assigned = reservations
            })
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

    // Swipe cell actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let reservation = getReservationsFor(indexPath.section)[indexPath.row]


        let assignAction = UITableViewRowAction(style: .Normal, title: "Назначить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
            print("assignAction", indexPath.row)
            
            reservation.setAssigned(<#T##boxIndex: Int##Int#>, washer: <#T##Washer#>, timeToWash: <#T##Int#>) {
                
            }
        })
        
        let reAssignAction = UITableViewRowAction(style: .Normal, title: "Переназначить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
            print("reAssignAction", indexPath.row)
        })


        let completeAction = UITableViewRowAction(style: .Normal, title: "Выполнен", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
            print("completeAction", indexPath.row)
            reservation.setComplete() {
                // TODO: push message to User
            }
        })
        completeAction.backgroundColor = UIColor.blueColor()

        let declineAction = UITableViewRowAction(style: .Default, title: "Отменить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in
            print("declineAction", indexPath.row)
            reservation.setDeclined()
        })


        if reservation.isDeclined() {
            return []
        }
        if reservation.isAssigned() {
            return [completeAction, reAssignAction, declineAction]
        } else {
            return [assignAction, declineAction]
        }
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
