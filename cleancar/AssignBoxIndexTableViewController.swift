//
//  AssignBoxIndexTableViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/4/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class AssignBoxIndexTableViewController: SelectRightBarButtonHelper {

    // identifiers
    let cellID = "boxIndexCell"
    let unwindSegueID = "unwindFromAssignBoxIndex"

    // variables
    var boxIndexes: [Int] = []
    var assignedBoxIndex: Int? {
        didSet {
            if assignedBoxIndex != nil {
                let itemAt: Int = self.boxIndexes
                    .enumerate()
                    .filter({ $0.element == assignedBoxIndex })
                    .first!.index
                self.assignedBoxIndexInTable =  NSIndexPath(forItem: itemAt, inSection: 0)
            }
        }
    }
    var assignedBoxIndexInTable: NSIndexPath?


    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.assignedBoxIndex != nil {
            self.tableView.selectRowAtIndexPath(self.assignedBoxIndexInTable, animated: false,scrollPosition: UITableViewScrollPosition.Top)

            self.updateSelectBarButtonStyle(true)
        }
    }
    
    
    
    override func clickedSelectBarButton(sender: UIBarButtonItem) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.assignedBoxIndex = self.boxIndexes[indexPath.row]
            self.performSegueWithIdentifier(unwindSegueID, sender: self)
        }
    }


    // dataSource methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.boxIndexes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(self.cellID, forIndexPath: indexPath)

        cell.textLabel!.text = "\(self.boxIndexes[indexPath.row])"
        return cell
    }
}
