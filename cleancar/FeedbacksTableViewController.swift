//
//  FeedbacksTableViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/7/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class FeedbacksTableViewController: UITableViewController {
    
    // identifiers
    let cellID = "feedbackCell"
    
    // variables
    var bySections: [String: [Reservation]] = [:] {
        didSet {
            if bySections.isEmpty {
                self.bySections = [textEmpty: []]
            }

            self.sections = bySections.map({ $0.0 })
            self.tableView.reloadData()
        }
    }
    var sections: [String] = []

    // constants
    let textEmpty = "Нет отзывов"


    override func viewDidLoad() {
        super.viewDidLoad()

        // 2. load data
        BookingHour.subscribeToToday({ () -> (Void) in
            let today = NSDate()

            Reservation.subscribeTo(.FeedbackReceived, date: today, completion: { (reservations) in
                // [Reservation] -> [timestamp_key: [Reservation]]
                self.bySections =
                    reservations.reduce([String: [Reservation]](), combine: { (var data, r) in

                        let key = formatAsString(r.timestamp, onlyDate: true)

                        if var updatedValue = data[key] {
                            updatedValue.append(r)
                            data.updateValue(updatedValue, forKey: key)
                        } else {
                            data.updateValue([r], forKey: key)
                        }
                        return data
                    })
            })
        })

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        setStatusBarBackgroundColor(UIColor.ccPurpleMedium())
    }
    override func viewDidDisappear(animated: Bool) {
        Reservation.unsubscribe()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.ccPurpleLight()
        headerView.backgroundView?.backgroundColor = UIColor.ccPurpleLight()
        headerView.tintColor = UIColor.whiteColor()
        headerView.textLabel?.textColor = UIColor.whiteColor()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getFeedbacksBy(section).count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! FeedbackTableViewCell

        let feedback = self.getFeedbacksBy(indexPath.section)[indexPath.row]
        cell.configure(feedback)

        return cell
    }


    
    // Swipe cell actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let feedback = self.getFeedbacksBy(indexPath.section)[indexPath.row]

        let callAction: UITableViewRowAction? = nil
        if feedback.user.accountKitProfile?["phone_number"] != nil {
            let callAction = UITableViewRowAction(style: .Default, title: "☎︎\nПозв..", handler: { (action: UITableViewRowAction, indexPath: NSIndexPath!) -> Void in

                let user = feedback.user
                let name = user.full_name
                let phone_number = user.accountKitProfile!["phone_number"] as! String
                displayCallAlert(phone_number, displayText: name, sender: self)
            })
            callAction.backgroundColor = UIColor.ccPurpleSuperLight()
        }

        return (callAction != nil) ? [callAction!] : []
    }
    

    
    func getFeedbacksBy(section: Int) -> [Reservation] {
        let sectionKey = self.sections[section],
            feedbacks = self.bySections[sectionKey]!
        return feedbacks
    }
    
}
