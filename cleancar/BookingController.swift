//
//  BookingController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/20/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase


class BookingController: UIViewController {

    // IBActions
    
    
    // IBOutlets
    
    
    // variables
    var bookingHour: BookingHour?


    override func viewDidLoad() {
        super.viewDidLoad()

        if self.navigationController != nil {
            print("here", self.navigationController?.viewControllers)
        }
        self.navigationController?.navigationBar.hidden = false
        
        print("heh =(")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

}
