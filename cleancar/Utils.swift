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
import UIKit


func setStatusBarBackgroundColor(color: UIColor) {
    guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
        return
    }
    statusBar.backgroundColor = color
}


extension UIViewController {
    func extSetNavigationBarStyle(backgroundColor: UIColor) {
        if let navBar = self.navigationController?.navigationBar {
            navBar.translucent = false
            navBar.barTintColor = backgroundColor
            navBar.tintColor = UIColor.ccTextColorGrayLight();
            navBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.ccTextColorGrayLight(),
                NSFontAttributeName: UIFont(name: "Helvetica", size: 14)!
            ]
        }
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}


// Color palette
extension UIColor {
    class func ccPurpleDark() -> UIColor {
        return UIColor(red:0.15, green:0.06, blue:0.27, alpha:1.0)
    }
    class func ccPurpleMedium() -> UIColor {
        return UIColor(red:0.25, green:0.11, blue:0.41, alpha:1.0)
    }
    class func ccPurpleLight() -> UIColor {
        return UIColor(red:0.33, green:0.10, blue:0.62, alpha:1.0)
    }
    class func ccPurpleSuperLight() -> UIColor {
        return UIColor(red:0.69, green:0.49, blue:0.96, alpha:1.0)
    }
    class func ccTextColorWhite() -> UIColor {
        return UIColor.whiteColor()
    }
    class func ccTextColorGray() -> UIColor {
        return UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    }
    class func ccTextColorGrayLight() -> UIColor {
        return UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
    }
}

// Sample text styles
extension UIFont {
    class func clnHeaderFont() -> UIFont {
        return UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
    }
}



func getFirebaseRef() -> FIRDatabaseReference {
    return FIRDatabase.database().reference()
}

func formatMoney(cost: Int) -> String {
    return "\(cost) ₸"
}


func formatAsTimestamp(date: NSDate) -> Int {
    return Int(date.timeIntervalSince1970)
}

func parseTimestamp(timestamp: Int) -> NSDate {
    let interval = NSTimeInterval(Double(timestamp)),
        date = NSDate(timeIntervalSince1970: interval)
    return date
}

func getCalendar() -> NSCalendar {
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    calendar.components([.YearForWeekOfYear, .WeekOfYear], fromDate: now)
    calendar.firstWeekday = 2
    return calendar
}

func formatAsString(date: NSDate) -> String {
    return getDateTimeFormatter().stringFromDate(date)
}

func formatAsString(date: NSDate, onlyDate: Bool) -> String {
    return (onlyDate ? getDateFormatter() : getDateTimeFormatter() ).stringFromDate(date)
}

func formatAsString(date: NSDate, inFormat: String) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = inFormat
    return formatter.stringFromDate(date)
}

func getCurrentHour() -> Int {
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components(.Hour, fromDate: now)
    return comp.hour
}

func getCurrentMinute() -> Int {
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components(.Minute, fromDate: now)
    return comp.minute
}

func getCurrentYear() -> Int {
    let now = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components(.Year, fromDate: now)
    return comp.year
}

func parseTime(date: String) -> NSDate {
    return getDateTimeFormatter().dateFromString(date)!
}

func getDateTimeFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}

func getDateFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}

func getMonth(date: NSDate, inFormat: String = "MM") -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale.currentLocale()
    formatter.dateFormat = inFormat
    return formatter.stringFromDate(date)
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


func displayCallAlert(phoneNumber: String, displayText: String, sender: UIViewController) {
    let alert = UIAlertController(title: "Позвонить?", message: displayText, preferredStyle: .Alert)

    let callAction = UIAlertAction(title: "Да", style: .Default, handler: { (alert: UIAlertAction!) -> Void in

        let parsedNumbers = String(phoneNumber.characters.filter { !" \n\t\r".characters.contains($0) })
        let telNumber = "tel://" + parsedNumbers
        UIApplication.sharedApplication().openURL(NSURL(string: telNumber)!)
    })
    let cancel = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)

    alert.addAction(callAction)
    alert.addAction(cancel)

    sender.presentViewController(alert, animated: true, completion: nil)
}

