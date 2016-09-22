//
//  CarInfo.swift
//  cleancar
//
//  Created by MacBook Pro on 8/22/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import SwiftyJSON


enum CarTypeEnum: Int {
    case Normal
    case CUV
    case SUV
    case VAN
}


class CarInfo {
    var type: CarTypeEnum
    var model: String?
    var identifierNumber: String?

    
    static let carTypeNames = ["Седан","Кроссовер","Внедорожник","Микроавтобус"]

    init() {
        self.type = .Normal
    }

    init(type: CarTypeEnum, model: String, identifierNumber: String) {
        self.type = type
        self.model = model
        self.identifierNumber = identifierNumber
    }

    init(data: AnyObject) {
        let parsed = JSON(data)
        self.type  = CarTypeEnum(rawValue: parsed["type"].intValue)!
        self.model = parsed["model"].string
        self.identifierNumber = parsed["identifier_number"].string
    }

    func getType() -> String {
        switch self.type {
        case .Normal:
            return "Легковая"
        case .CUV:
            return "Кроссовер"
        case .SUV:
            return "Внедорожник"
        case .VAN:
            return "Крупные внедорожники"
        }
    }

    func toDict() -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "type": self.type.rawValue,
            "model": self.model!,
            "identifier_number": self.identifierNumber!
        ]
        return data
    }

}

