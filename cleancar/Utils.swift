//
//  Utils.swift
//  cleancar
//
//  Created by MacBook Pro on 8/30/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase



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
