//
//  AssignWasherTableViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/3/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class AssignWasherTableViewController: SelectRightBarButtonHelper {

    // identifiers
    let cellID = "washerCell"
    let unwindSegueID = "unwindFromAssignWasher"


    // variables
    var washers: [Washer] = []
    var assignedWasher: Washer? {
        didSet {
            if assignedWasher != nil {
                let assignedWasherIndex: Int = self.washers
                    .enumerate()
                    .filter({ $0.element.id == assignedWasher!.id })
                    .first!.index
                self.assignedWasherIndexPath =  NSIndexPath(forItem: assignedWasherIndex, inSection: 0)
            }
        }
    }
    var assignedWasherIndexPath: NSIndexPath?


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if self.assignedWasher != nil {
            self.tableView.selectRowAtIndexPath(self.assignedWasherIndexPath, animated: false,scrollPosition: UITableViewScrollPosition.Top)

            self.updateSelectBarButtonStyle(true)
        }
    }


    override func clickedSelectBarButton(sender: UIBarButtonItem) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.assignedWasher = self.washers[indexPath.row]
            self.performSegueWithIdentifier(unwindSegueID, sender: self)
        }
    }


    // dataSource methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.washers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(self.cellID, forIndexPath: indexPath) as! AssignWasherTableViewCell

        cell.configure(self.washers[indexPath.row])
        return cell
    }

}


