//
//  SelectTableViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/16/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class SelectTableViewController: UITableViewController {

    // constants
    let cellID = "cell"
    let segueUnwindID = "unwindSegue"


    // variabls
    var items: [String]!
    var selectedIndex: Int?
    var sourceType: SelectTableSources?


    override func viewDidLoad() {
        super.viewDidLoad()

        // add right Bar button
        let saveButton = UIBarButtonItem(
            title: "Выбрать",
            style: .Plain,
            target: self,
            action: #selector(clickedSelectBarButton(_:))
        )
        saveButton.enabled = false
        self.navigationItem.rightBarButtonItem = saveButton
    }


    // data source methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(self.cellID, forIndexPath: indexPath) 

        cell.textLabel!.text = self.items[indexPath.row]
        return cell
    }

    // delegate methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateSelectBarButtonStyle(true)
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateSelectBarButtonStyle(false)
    }


    func clickedSelectBarButton(sender: UIBarButtonItem) {
        self.selectedIndex = self.tableView.indexPathForSelectedRow?.row
        self.performSegueWithIdentifier(segueUnwindID, sender: self)
    }

    func updateSelectBarButtonStyle(isActive: Bool) {
        let saveButton: UIBarButtonItem = self.navigationItem.rightBarButtonItem!
        saveButton.style = isActive ? .Done : .Plain
        saveButton.enabled = isActive
    }
}
