//
//  ActivityIndicatorViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 11/13/16.
//
//

import UIKit

class ActivityIndicatorViewController: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelDescription: UILabel!
    
    // variables
    var textDescription: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        labelDescription.text = self.textDescription
        activityIndicator.startAnimating()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        activityIndicator.stopAnimating()
    }


}
