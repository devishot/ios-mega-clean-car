//
//  SaveBarButton.swift
//  cleancar
//
//  Created by MacBook Pro on 9/4/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import UIKit


protocol SelectRightBarButtonProtocol {

    func clickedSelectBarButton(sender: UIBarButtonItem)
    func updateSelectBarButtonStyle(isActive: Bool)
}

class SelectRightBarButtonHelper: UITableViewController, SelectRightBarButtonProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set right Bar button
        let saveButton = UIBarButtonItem(
            title: "Выбрать",
            style: .Plain,
            target: self,
            action: #selector(clickedSelectBarButton(_:))
        )
        self.navigationItem.rightBarButtonItem = saveButton
    }

    func clickedSelectBarButton(sender: UIBarButtonItem) {
        // override this method
        // 1. save selected into controller's variable
        // 2. call unwindSegue:

        if let indexPath = self.tableView.indexPathForSelectedRow {
            // example: self.performSegueWithIdentifier(unwindSegueID, sender: self)
        }
    }

    func updateSelectBarButtonStyle(isActive: Bool) {
        self.navigationItem.rightBarButtonItem?.style = isActive ? .Done : .Plain
    }

    // delegate method
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateSelectBarButtonStyle(true)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.updateSelectBarButtonStyle(false)
    }
}
