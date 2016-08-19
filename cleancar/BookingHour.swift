//
//  BookingHour.swift
//  cleancar
//
//  Created by MacBook Pro on 8/19/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON


// Global variables and functions
func getFirebaseRef() -> FIRDatabaseReference {
    return FIRDatabase.database().reference()
}


class BookingHour {
    var index: Int
    var boxes: [Bool]
    var washers: [String: Bool]


    static var refHandle: FIRDatabaseHandle?


    init(index: Int, data: AnyObject) {
        let data = JSON(data)

        self.index = index
        self.boxes = data["boxes"].arrayValue.map {$0.boolValue}

        // [String: JSON] -> [String: Bool]
        let dict: [String: JSON] = data["washers"].dictionaryValue
        self.washers = [String: Bool]()
        for (key, value) in dict {
            self.washers.updateValue(value.boolValue, forKey: key)
        }
    }

    func getHour() -> String {
        let addingMinutes = index * 30
        // 09:00
        let startHour = 9
        let startMinute = 0
        // 09:00 + 150 minute = 11:30
        let hour = startHour + (startMinute + addingMinutes) / 60
        let minute = (startMinute + addingMinutes) % 60
        
        func f(x: Int) -> String {
            if x < 10 {
                return "0\(x)"
            }
            else {
                return "\(x)"
            }
        }
        return "\(f(hour)):\(f(minute))"
    }

    class func subscribeToData(callback: (snapshot: FIRDataSnapshot) -> Void) {
        BookingHour.refHandle = getFirebaseRef()
            .child("booking_hours")
            .observeEventType(FIRDataEventType.Value, withBlock: callback)
    }

    class func unsubscribe() {
        if let ref = BookingHour.refHandle {
            getFirebaseRef().removeObserverWithHandle(ref)
        }
    }
}


