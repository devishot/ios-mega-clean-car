//
//  TabBarViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/18/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    // variables
    var forClient: [UIViewController] = []
    var forAdmin: [UIViewController] = []
    var forOwner: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let allControllers = self.viewControllers!
        self.viewControllers = []

        self.forOwner = allControllers
        self.forAdmin = [] + allControllers[0...3]
        self.forClient = [] + allControllers[0...1]

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let user = User.current!
        let role: UserRoles = user.role
        switch role {
        case .Client:
            self.viewControllers = forClient
        case .Admin:
            self.viewControllers = forAdmin
        case .Owner:
            self.viewControllers = forOwner
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
