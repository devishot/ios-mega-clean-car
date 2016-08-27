//
//  LoginCheckViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/27/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class LoginCheckViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var codeTextField: UITextField!
    
    
    // constants
    let homeViewControllerSegueID = "home"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController!.navigationBar.barTintColor = UIColor(red: 216.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == homeViewControllerSegueID {
            let homeController = segue.destinationViewController as! HomeViewController

            // TODO: signup and login
        }
    }
}
