//
//  ServicesTableViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/23/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class ServicesTableViewController: UITableViewController {
    
    // IBOutlets controls
    @IBOutlet weak var washingTypeControl: UISegmentedControl!
    @IBOutlet weak var engineCleaningSwitch: UISwitch!
    @IBOutlet weak var trunkCleaningSwitch: UISwitch!
    @IBOutlet weak var interierPolishingSwitch: UISwitch!
    @IBOutlet weak var bodyWeaningSwitch: UISwitch!
    @IBOutlet weak var matsCountStepper: UIStepper!


    // IBOutlets labels
    @IBOutlet weak var bodyWashingCostLabel: UILabel!
    @IBOutlet weak var salonWashingCostLabel: UILabel!
    @IBOutlet weak var bodyAndSalonWashingCostLabel: UILabel!

    @IBOutlet weak var engineCleaningCostLabel: UILabel!
    @IBOutlet weak var trunkCleaningCostLabel: UILabel!
    @IBOutlet weak var interierPolishingCostLabel: UILabel!
    @IBOutlet weak var bodyWeaningCostLabel: UILabel!

    @IBOutlet weak var matsCountLabel: UILabel!
    @IBOutlet weak var matsCountCostLabel: UILabel!


    // IBActions
    @IBAction func changedWashingType(sender: UISegmentedControl) {
        let washingType = WashTypeEnum(rawValue: sender.selectedSegmentIndex)
        self.selectedServices = self.selectedServices.update(washingType!)
    }
    @IBAction func clickedEngineCleaning(switchState: UISwitch) {
        self.selectedServices = self.selectedServices.selectAdditional(switchState.on, key: .EngineCleaning)
    }
    @IBAction func clickedTrunkCleaning(switchState: UISwitch) {
        self.selectedServices = self.selectedServices.selectAdditional(switchState.on, key: .TrunkCleaning)
    }
    @IBAction func clickedInterierPolishing(switchState: UISwitch) {
        self.selectedServices = self.selectedServices.selectAdditional(switchState.on, key: .InterierPolishing)
    }
    @IBAction func clickedBodyWeaning(switchState: UISwitch) {
        self.selectedServices = self.selectedServices.selectAdditional(switchState.on, key: .BodyWeaning)
    }
    @IBAction func changedMatsCount(sender: UIStepper) {
        self.selectedServices = self.selectedServices.update(Int(sender.value))
    }


    // variables
    var selectedServices: Services = Services() {
        didSet {
            // update cost labels
            engineCleaningCostLabel.text = selectedServices.getCostFor(.EngineCleaning)
            trunkCleaningCostLabel.text = selectedServices.getCostFor(.TrunkCleaning)
            interierPolishingCostLabel.text = selectedServices.getCostFor(.InterierPolishing)
            bodyWeaningCostLabel.text = selectedServices.getCostFor(.BodyWeaning)

            bodyWashingCostLabel.text = selectedServices.getCostFor(.Body)
            salonWashingCostLabel.text = selectedServices.getCostFor(.Salon)
            bodyAndSalonWashingCostLabel.text = selectedServices.getCostFor(.BodyAndSalon)

            // update stepper labels
            matsCountCostLabel.text = selectedServices.getCostForCleanMats()
            matsCountLabel.text = selectedServices.getCountForCleanMats()

            // call callback
            updateTotal!(selectedServices.getCostForTotal())
        }
    }

    var updateTotal: ((String) -> ())?

}
