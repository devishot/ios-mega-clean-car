//
//  BookingHour.swift
//  cleancar
//
//  Created by MacBook Pro on 8/19/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import SwiftyJSON


class BookingHour {
    var index: Int
    var boxes: [Bool]
    var washers: [String: Bool]
    
    init(index: Int, data: JSON) {
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
}