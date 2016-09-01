//
//  Utils.swift
//  cleancar
//
//  Created by MacBook Pro on 8/30/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON


func getFirebaseRef() -> FIRDatabaseReference {
    return FIRDatabase.database().reference()
}

func formatMoney(cost: Int) -> String {
    return "\(cost) ₸"
}


func formatAsTimestamp(date: NSDate) -> Int {
    return date.timeIntervalSince1970.hashValue
}

func parseTimestamp(timestamp: Int) -> NSDate {
    let interval = NSTimeInterval(timestamp)
    return NSDate(timeIntervalSince1970: interval)
}

func formatAsString(date: NSDate) -> String {
    return getDateFormatter().stringFromDate(date)
}

func parseTime(date: String) -> NSDate {
    return getDateFormatter().dateFromString(date)!
}

func getDateFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "dd-mm-yyyy HH:mm:ss"
    return formatter
}


private var kAssociationKeyNextField: UInt8 = 0

extension UITextField {
    var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}


func transformWord(word: String, amount: Int) -> String {
    var prefix: String = ""
    if amount > 1 && amount <= 4 {
        prefix = "а"
    }
    if amount > 4 {
        prefix = "ов"
    }
    return "\(word)\(prefix)"
}

func toStringBool(data: [String:JSON]) -> [String: Bool] {
    var ret = [String: Bool]()
    for (key, value) in data {
        ret.updateValue(value.boolValue, forKey: key)
    }
    return ret
}

func toStringString(data: [String:JSON]) -> [String: String] {
    var ret = [String: String]()
    for (key, value) in data {
        ret.updateValue(value.stringValue, forKey: key)
    }
    return ret
}

func toStringAnyObject(data: [String:JSON]) -> [String: AnyObject] {
    var ret = [String: AnyObject]()
    for (key, value) in data {
        ret.updateValue(value.rawValue, forKey: key)
    }
    return ret
}



func displayPromptView(title: String, self: UIViewController, completion: (value: Bool) -> (Void)) {
    let alert = UIAlertController(title: nil, message: title, preferredStyle: .Alert)

    let logOut = UIAlertAction(title: "Да", style: .Destructive,
                               handler: { (alert: UIAlertAction!) -> Void in
                                completion(value: true)
    })
    
    let cancel = UIAlertAction(title: "Нет", style: .Cancel,
                               handler: {
                                (alert: UIAlertAction!) -> Void in
                                completion(value: false)
    })
    
    alert.addAction(logOut)
    alert.addAction(cancel)
    
    self.presentViewController(alert, animated: true, completion: nil)
}


