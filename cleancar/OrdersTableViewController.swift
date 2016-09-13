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

        // update views:
        self.filterButton.title = self.filterNames[(self.filterValue + 1) % 2]
        self.tableView.reloadData()
    }
    @IBAction func unwindAssignToReservation(unwindSegue: UIStoryboardSegue) {
        self.setFromAssignToReservationViewController(unwindSegue)
    }


    // identifiers
    let segueAssignToReservationID = "assignToReservation"

    
    // constants
    let filterNames = ["Все", "Отмененные"]
    let sections = [
        ["Новые", "Назначенные"],
        ["Отмененные"]
    ]


    // variables
    var filterValue: Int = 0
    var selectedReservation: Reservation?

    var nonAssigned: [Reservation] = [] {
        didSet {
            if self.filterValue == 0 {
                self.tableView.reloadData()
            }
        }
    }
    var assigned: [Reservation] = [] {
        didSet {
            if self.filterValue == 0 {
                self.tableView.reloadData()
            }
        }
    }
    var declined: [Reservation] = [] {
        didSet {
            if self.filterValue == 1 {
                self.tableView.reloadData()
            }
        }
    }


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
                //print(".subscribeTo.Declined", reservations.count)
                self.declined = reservations
            })
        })
    }

    override func viewDidDisappear(animated: Bool) {
        Reservation.unsubscribe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueAssignToReservationID {
            let indexPath = sender as! NSIndexPath
            self.setToAssignToReservationViewController(segue, indexPath: indexPath)
        }
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections[filterValue].count
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

        let assignAction = UITableViewRowAction(style: .Normal, title: "\u{2606}\n Назначить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })

        let reAssignAction = UITableViewRowAction(style: .Normal, title: "\u{2606}\n Изменить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })

        let completeAction = UITableViewRowAction(style: .Normal, title: "\u{2605}\n Выполнен", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            reservation.setCompleted() {
                // TODO: push message to User
            }
        })
        completeAction.backgroundColor = UIColor.blueColor()

        let declineAction = UITableViewRowAction(style: .Default, title: "\u{267A}\n Отменить", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            reservation.setDeclined() {
                // TODO: push message to User
            }
        })


        if self.filterValue == 1 {
            return []
        }
        if reservation.isAssigned() {
            return [completeAction, reAssignAction, declineAction]
        } else {
            return [assignAction, declineAction]
        }
    }



    func setToAssignToReservationViewController(segue: UIStoryboardSegue, indexPath: NSIndexPath) {
        let destController = segue.destinationViewController as! AssignToReservationViewController
    
        let reservation = getReservationsFor(indexPath.section)[indexPath.row]
        self.selectedReservation = reservation
    
        destController.bookingHour = reservation.bookingHour
        if reservation.isAssigned() {
            destController.valueBoxIndex = reservation.boxIndex
            destController.valueWasher = reservation.washer
            destController.valueTimeToWash = reservation.timeToWash
        }
    }

    func setFromAssignToReservationViewController(unwindSegue: UIStoryboardSegue) {
        let sourceController = unwindSegue.sourceViewController as! AssignToReservationViewController
        
        let reservation = self.selectedReservation!
        reservation.setAssigned(
            sourceController.valueBoxIndex!,
            washer: sourceController.valueWasher!,
            timeToWash: sourceController.valueTimeToWash!
        ){}
    }


    func getReservationsFor(section: Int) -> [Reservation] {
        if self.filterValue == 0 {
            return (section == 0) ? self.nonAssigned : self.assigned
        } else {
            return self.declined
        }
    }

}
