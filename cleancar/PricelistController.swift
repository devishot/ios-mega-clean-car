//
//  PricelistController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/19/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit


class PricelistController: UIViewController {

    // outlets
    @IBOutlet weak var segmentViewCarTypes: UISegmentedControl!
    
    // actions
    @IBAction func changedSegmentViewCarTypes(sender: UISegmentedControl) {
        self.selectedCarType = CarTypeEnum(rawValue: sender.selectedSegmentIndex)!
        self.tablePrices?.tableView.reloadData()
    }

    // constants
    let segueEmbeddedTableViewID = "pricesTable"
    let cellOfTablePriceID = "cellWithDetail"

    // variables
    var tablePrices: UITableViewController?
    var selectedCarType: CarTypeEnum = CarTypeEnum.Normal


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set styles
        segmentViewCarTypes.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orangeColor()], forState: UIControlState.Normal)
        segmentViewCarTypes.setFontSize(10)

        // init
        segmentViewCarTypes.selectedSegmentIndex = CarTypeEnum.Normal.rawValue
        tablePrices?.tableView.dataSource = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueEmbeddedTableViewID {
            self.tablePrices = segue.destinationViewController as? UITableViewController
        }
    }

}


extension PricelistController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getServices(getName: true).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tablePrices!.tableView.dequeueReusableCellWithIdentifier(self.cellOfTablePriceID, forIndexPath: indexPath)
        let row = indexPath.row,
            carType = self.selectedCarType.rawValue,
            service = getServices(true)[row],
            serviceName = getServices(getName: true)[row],
            cost = Services.costs[carType]![service]!

        cell.textLabel?.text = serviceName
        cell.detailTextLabel?.text = formatMoney(cost)
        return cell
    }
}


