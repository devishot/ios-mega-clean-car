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
            let today = NSDate()

            Reservation.subscribeTo(.NonAssigned, date: today, completion: { (reservations) in
                self.nonAssigned = reservations
            })
            Reservation.subscribeTo(.Assigned, date: today, completion: { (reservations) in
                self.assigned = reservations
            })
            Reservation.subscribeTo(.Declined, date: today, completion: { (reservations) in
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

        let assignAction = UITableViewRowAction(style: .Normal, title: "✚\n Assign", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })

        let reAssignAction = UITableViewRowAction(style: .Normal, title: "✚\n Re-Assign", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })

        let completeAction = UITableViewRowAction(style: .Normal, title: "✔︎\n Done", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            reservation.setCompleted() {
                // TODO: push message to User
            }
        })
        completeAction.backgroundColor = UIColor.blueColor()

        let declineAction = UITableViewRowAction(style: .Default, title: "✖︎\n Delete", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            displayPromptView("Хотите отменить заказ?", self: self) { (result: Bool) in
                if result == true {
                    reservation.setDeclined() {
                        // TODO: push message to User
                    }
                }
            }
        })

        let callAction: UITableViewRowAction? = nil
        if reservation.user.accountKitProfile?["phone_number"] != nil {
            let callAction = UITableViewRowAction(style: .Default, title: "✆\n Call", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

                self.displayCallAlert(reservation.user)
            })
        }


        if self.filterValue == 1 {
            if callAction != nil {
                return [callAction!]
            }
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
    
    
    func displayCallAlert(user: User) {
        let name = user.full_name
        let phone_number = user.accountKitProfile!["phone_number"]!

        let alert = UIAlertController(title: "Позвонить?", message: name, preferredStyle: .Alert)

        let callAction = UIAlertAction(title: "Да", style: .Default, handler: { (alert: UIAlertAction!) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "tel:\(phone_number)")!)
        })

        let cancel = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)

        alert.addAction(callAction)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
