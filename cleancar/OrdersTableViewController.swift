//
//  OrdersTableViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 23.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


private enum OrdersPageFilters: Int {
    case Quequed
    case Canceled

    
    func getTitle() -> String {
        switch self {
        case .Quequed:
            return "Заказы"
        case .Canceled:
            return "Отмененные"
        }
    }
    
    func opposite() -> OrdersPageFilters {
        switch self {
        case .Quequed:
            return .Canceled
        case .Canceled:
            return .Quequed
        }
    }
}


class OrdersTableViewController: UITableViewController {

    // IBOutlets
    @IBOutlet weak var filterButton: UIBarButtonItem!


    // IBActions
    @IBAction func clickedFilterButton(sender: UIBarButtonItem) {
        self.filterValue = self.filterValue.opposite()
    }
    @IBAction func unwindAssignToReservation(unwindSegue: UIStoryboardSegue) {
        self.setFromAssignToReservationViewController(unwindSegue)
    }


    // identifiers
    let segueAssignToReservationID = "assignToReservation"


    // constants
    var sections = [
        ["Новые", "Назначенные"],
        ["Сегодня"]
    ]


    // variables
    private var filterValue: OrdersPageFilters = .Quequed {
        didSet {
            // change Nav bar's title
            switch filterValue {
            case .Quequed:
                self.tabBarController?.navigationItem.title = filterValue.getTitle()
            case .Canceled:
                 self.tabBarController?.navigationItem.title = ""
            }
            // update Nav bar's right
            self.filterButton.title = filterValue.opposite().getTitle()
            self.tableView.reloadData()
        }
    }
    private var selectedReservation: Reservation?


    private var nonAssigned: [Reservation] = [] {
        didSet {
            if self.filterValue == .Quequed {
                self.tableView.reloadData()
            }
        }
    }
    private var assigned: [Reservation] = [] {
        didSet {
            if self.filterValue == .Quequed {
                self.tableView.reloadData()
            }
        }
    }
    private var declined: [Reservation] = [] {
        didSet {
            if self.filterValue == .Canceled {
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setStatusBarBackgroundColor(UIColor.ccPurpleMedium())
        self.extSetNavigationBarStyle(UIColor.ccPurpleMedium())
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
        let filter = self.filterValue.rawValue
        return self.sections[filter].count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let filter = self.filterValue.rawValue
        return self.sections[filter][section]
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundView?.backgroundColor = UIColor.ccPurpleLight()
        headerView.tintColor = UIColor.whiteColor()
        headerView.textLabel?.textColor = UIColor.whiteColor()
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

        let assignAction = UITableViewRowAction(style: .Normal, title: "✚\nНазн..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })
        assignAction.backgroundColor = UIColor.ccPurpleSuperLight()

        let reAssignAction = UITableViewRowAction(style: .Normal, title: "✎\nНазн..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            self.performSegueWithIdentifier(self.segueAssignToReservationID, sender: indexPath)
        })
        reAssignAction.backgroundColor = UIColor.ccPurpleSuperLight()

        let completeAction = UITableViewRowAction(style: .Normal, title: "✔︎\nВыпо..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

                reservation.setCompleted() {
                    // TODO: push message to User
                }
        })
        completeAction.backgroundColor = UIColor.ccPurpleSuperLight()

        let declineAction = UITableViewRowAction(style: .Default, title: "✖︎\nУдал..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

            displayPromptView("Хотите отменить заказ?", self: self) { (result: Bool) in
                if result == true {
                    reservation.setDeclined() {
                        // TODO: push message to User
                    }
                }
            }
        })

        var callAction: UITableViewRowAction? = nil
        if reservation.user.accountKitProfile?["phone_number"] != nil {
            callAction = UITableViewRowAction(style: .Normal, title: "☎︎\nПозв..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

                let user = reservation.user
                let name = user.full_name
                let phone_number = user.accountKitProfile!["phone_number"]?.string
                displayCallAlert(phone_number!, displayText: name, sender: self)
            })
            callAction!.backgroundColor = UIColor.ccPurpleSuperLight()
        }


        var actions = []
        switch self.filterValue {
        case .Canceled:
            break
        case .Quequed:
            if reservation.isAssigned() {
                actions = (callAction != nil)
                    ? [completeAction, reAssignAction, callAction!, declineAction]
                    : [completeAction, reAssignAction, declineAction]
            } else {
                actions = (callAction != nil)
                    ? [assignAction, callAction!, declineAction]
                    : [assignAction, declineAction]
            }
        }
        return actions as! [UITableViewRowAction]
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
        switch self.filterValue {
        case .Quequed:
            return (section == 0) ? self.nonAssigned : self.assigned
        case .Canceled:
            return self.declined
        }
    }

}
