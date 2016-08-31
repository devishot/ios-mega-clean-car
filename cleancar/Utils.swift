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


