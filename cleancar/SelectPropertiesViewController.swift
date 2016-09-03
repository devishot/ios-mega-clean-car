//
//  SelectPropertiesViewController.swift
//  cleancar
//
//  Created by Aigerim'sMac on 02.09.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit

class SelectPropertiesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonBorder: UIButton!
    @IBOutlet weak var durationCollectionView: UICollectionView!

    //actions
    @IBAction func sendButton(sender: UIButton) {
    }

    //variables
    var selectedIndex: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonBorder.layer.masksToBounds = true
        buttonBorder.layer.cornerRadius = 5


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("durationCell", forIndexPath: indexPath) as! DurationCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.configure(indexPath.row, isSelected:true)
       
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if self.selectedIndex == indexPath.row {
            
            self.selectedIndex = nil
            
        } else {
            
            self.selectedIndex = indexPath.row
            
        }
    }

}