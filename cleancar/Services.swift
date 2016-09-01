//
//  Services.swift
//  cleancar
//
//  Created by MacBook Pro on 8/22/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import SwiftyJSON


enum WashTypeEnum: Int {
    case Body = 0
    case Salon = 1
    case BodyAndSalon = 2
}

enum AdditionalsEnum: String {
    case EngineCleaning
    case TrunkCleaning
    case InterierPolishing
    case BodyWeaning
}


let WashTypeName = ["Кузов", "Салон", "Кузов-салон"]
let AdditionalsName = [
    "EngineCleaning": "Мойка двигателя",
    "TrunkCleaning": "Чистка багажника",
    "InterierPolishing": "Полировка салона",
    "BodyWeaning": "Отбивка кузова"
]
let CleanMatsName = "Чистка ковров"



class Services {
    var carType: CarTypeEnum
    var washType: WashTypeEnum
    var additionalSelect: [String: Bool] = [:]
    var cleanMatsCount: Int = 0

    static let costs: [Int: [String: Int]] = [
        0: [
            "0": 1800, //Body
            "1": 1000,//Salon
            "2": 2800,//BodyAndSalon
            "EngineCleaning": 4000,
            "TrunkCleaning": 500,
            "InterierPolishing": 500,
            "BodyWeaning": 800,
            "CleanMatsPerCount": 100
        ],
        1: [
            "0": 2100,
            "1": 1400,
            "2": 3500,
            "EngineCleaning": 4000,
            "TrunkCleaning": 500,
            "InterierPolishing": 600,
            "BodyWeaning": 900,
            "CleanMatsPerCount": 100
        ],
        2: [
            "0": 2300,
            "1": 1500,
            "2": 3800,
            "EngineCleaning": 4000,
            "TrunkCleaning": 600,
            "InterierPolishing": 800,
            "BodyWeaning": 1000,
            "CleanMatsPerCount": 100
        ],
        3: [
            "0": 2400,
            "1": 1600,
            "2": 4000,
            "EngineCleaning": 4000,
            "TrunkCleaning": 600,
            "InterierPolishing": 800,
            "BodyWeaning": 1100,
            "CleanMatsPerCount": 100
        ],
    ]


    func toDict() -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "car_type": carType.rawValue,
            "wash_type": washType.rawValue,
            "additional_select": additionalSelect as NSDictionary,
            "clean_mats_count": cleanMatsCount,
            "total": getCostForTotal()
        ]
        return data
    }


    init() {
        self.carType = .Normal
        self.washType = .Body
    }

    init(carType: CarTypeEnum, washType: WashTypeEnum) {
        self.carType = carType
        self.washType = washType
    }
    
    init(carType: CarTypeEnum, washType: WashTypeEnum, additionalSelect: [String: Bool], cleanMatsCount: Int) {
        self.carType = carType
        self.washType = washType
        self.additionalSelect = additionalSelect
        self.cleanMatsCount = cleanMatsCount
    }

    init(data: AnyObject) {
        let parsed = JSON(data)
        self.carType = CarTypeEnum(rawValue: parsed["car_type"].intValue)!
        self.washType = WashTypeEnum(rawValue: parsed["wash_type"].intValue)!
        self.additionalSelect = toStringBool(parsed["additional_select"].dictionaryValue)
        self.cleanMatsCount = parsed["clean_mats_count"].intValue
    }


    func update(newWashType: WashTypeEnum) -> Services {
        return Services(carType: self.carType, washType: newWashType, additionalSelect: self.additionalSelect, cleanMatsCount: self.cleanMatsCount)
    }

    func update(newCarType: CarTypeEnum) -> Services {
        return Services(carType: newCarType, washType: self.washType, additionalSelect: self.additionalSelect, cleanMatsCount: self.cleanMatsCount)
    }

    func update(newCleanMatsCount: Int) -> Services {
        return Services(carType: self.carType, washType: self.washType, additionalSelect: self.additionalSelect, cleanMatsCount: newCleanMatsCount)
    }

    func selectAdditional(value: Bool, key: AdditionalsEnum) -> Services {
        var updatedSelects = self.additionalSelect
        updatedSelects.updateValue(value, forKey: key.rawValue)

        return Services(carType: self.carType, washType: self.washType, additionalSelect: updatedSelects, cleanMatsCount: self.cleanMatsCount)
    }


    func getCostFor(additionType: AdditionalsEnum) -> Int {
        return getCostFor(additionType.rawValue)
    }

    func getCostFor(washingType: WashTypeEnum) -> Int {
        return getCostFor(String(washingType.rawValue))
    }

    func getCostFor(key: String) -> Int {
        return Services.costs[self.carType.rawValue]![key]!
    }

    func getCostForCleanMats() -> Int {
        let cost = Services.costs[self.carType.rawValue]!["CleanMatsPerCount"]! * self.cleanMatsCount
        return cost
    }

    func getCountForCleanMats() -> String {
        return "\(self.cleanMatsCount) ед."
    }

    func getCostForTotal() -> Int {
        var cost: Int = 0
        
        // washType
        cost += Services.costs[self.carType.rawValue]![String(self.washType.rawValue)]!
        // selected additionals
        cost += additionalSelect.reduce(0) { acc, nextValue in
            if nextValue.1 {
                return acc + Services.costs[self.carType.rawValue]![nextValue.0]!
            }
            return acc
        }
        // cleanMats per count
        cost += Services.costs[self.carType.rawValue]!["CleanMatsPerCount"]! * self.cleanMatsCount

        return cost
    }
    
    func getDescription() -> String {
        let sep = " / "

        let desc = WashTypeName[self.washType.rawValue]
        let additionals = self.additionalSelect
                .map({ $0.1 ? AdditionalsName[$0.0]! : "" })
                .joinWithSeparator(sep)
        let mats = self.cleanMatsCount > 0 ? "\(CleanMatsName) (\(self.cleanMatsCount)шт.)" : ""

        return [desc, additionals, mats].joinWithSeparator(sep)
    }
}

