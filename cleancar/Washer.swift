//
//  Washer.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase


class Washer: FirebaseDataProtocol {
    static var all: [String: Washer] = [:]
    static let childRefName: String = "washers"


    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    func toDict(withId: Bool = false) -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "name": name
        ]
        if withId {
            data.setObject(self.id, forKey: "id")
        }
        return data
    }


    class func fetchData(callback: () -> (Void)) {
        getFirebaseRef()
            .child(Washer.childRefName)
            .observeSingleEventOfType(.Value) {
                (snapshot: FIRDataSnapshot) -> Void in

                let values = snapshot.value as! [String:[String: AnyObject]]

                var data: [String: Washer] = [:]
                for (id, value) in values {
                    data[id] = Washer(id: id, name: value["name"] as! String)
                }
                Washer.all = data

                callback()
            }
    }

}