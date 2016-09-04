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


class BookingHour {
    static let childRefName: String = "booking_hours"
    static var refHandle: FIRDatabaseHandle?

    static let minuteMultiplier: Int = 30
    static let allBoxIndexes: [Int] = [1,2,3,4,5,6]
    static var today: [BookingHour] = []

    var index: Int
    var boxes: [Bool]
    var washers: [String: Bool]
    var nonAssignedReservationIds: [String]


    init(index: Int, data: AnyObject) {
        let parsed = JSON(data)

        self.index = index
        self.boxes = parsed["boxes"].arrayValue.map {$0.boolValue}
        self.washers = toStringBool(parsed["washers"].dictionaryValue)
        self.nonAssignedReservationIds = parsed["non_assigned"].arrayValue.map({$0.stringValue})
    }

    init(index: Int, boxes: [Bool], washers: [String:Bool]) {
        self.index = index
        self.boxes = boxes
        self.washers = washers
        self.nonAssignedReservationIds = []
    }

    func toDict() -> NSDictionary {
        let data = [
            "boxes": boxes,
            "washers": washers,
            "non_assigned": nonAssignedReservationIds
        ]
        return data
    }

    
    func getHour() -> String {
        let addingMinutes = index * BookingHour.minuteMultiplier
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

    func getStatus() -> String {
        let freeBoxesCount =
            self.getFreeBoxIndexes().count - self.nonAssignedReservationIds.count
        return self.isFree()
            ? "\(freeBoxesCount) \(transformWord("бокс", amount: freeBoxesCount))"
            : "Занято"
    }

    func isFree() -> Bool {
        return self.getFreeBoxIndexes().count - self.nonAssignedReservationIds.count > 0
    }

    func getFreeBoxIndexes() -> [Int] {
        return self.boxes.enumerate()
            .reduce([]) { $1.element ? $0 + [$1.index] : $0 }
    }


    func reserve(timeToWash: Int = 1) -> [String: AnyObject] {
        let required = _getRequiredBookingHours(timeToWash),
            boxIndex = _getFreeBox(required),
            washer = _getFreeWasher(required)

        var data: [String: AnyObject] = [
            "boxIndex": boxIndex,
            "washer": washer
        ]

        let updated: [BookingHour] = required.map({ bookingHour in
            var updBoxes = bookingHour.boxes,
                updWashers = bookingHour.washers
            updBoxes[boxIndex] = false
            updWashers[washer.id] = false

            return BookingHour(
                index: bookingHour.index,
                boxes: updBoxes,
                washers: updWashers
            )
        })
        data["bookingHours"] = updated

        return data
    }

    func _getFreeBox(required: [BookingHour]) -> Int {
        func getFreeBoxIndexes(bookingHour: BookingHour) -> [Int] {
            var indexes: [Int] = []
            for (index, isFree) in bookingHour.boxes.enumerate() {
                if isFree {
                    indexes.append(index)
                }
            }
            return indexes
        }
        let t = required.map(getFreeBoxIndexes).map { Set($0) }
        let freeBoxIndexes = t.reduce(t[0]) { acc, indexes in
            acc.intersect(indexes)
        }

        // TODO: catch when zero indexes
        return freeBoxIndexes.first!
    }

    func _getFreeWasher(required: [BookingHour]) -> Washer {
        func getFreeWasherIds(bookingHour: BookingHour) -> [String] {
            var indexes: [String] = []
            for (wid, isFree) in bookingHour.washers {
                if isFree {
                    indexes.append(wid)
                }
            }
            return indexes
        }
        let t = required.map(getFreeWasherIds).map { Set($0) }
        let freeBoxIndexes = t.reduce(t[0]) { acc, indexes in
            acc.intersect(indexes)
        }
 
        // TODO: catch when zero indexes
        return Washer.all[freeBoxIndexes.first!]!
    }

    func _getRequiredBookingHours(timeToWash: Int) -> [BookingHour] {
        let requiredTime = timeToWash * Reservation.timeToWashMinuteMultiplier,
            t = Float(requiredTime) / Float(BookingHour.minuteMultiplier),
            requiredAmount = Int(round(t))

        return BookingHour.today
            .enumerate()
            .filter() { (index, bookingHour) in
                index >= self.index && index < self.index+requiredAmount
            }
            .map(){ (index, bookingHour) in bookingHour }
    }


    // firebase
    class func subscribeToToday(callback: () -> (Void) ) {
        BookingHour.refHandle = getFirebaseRef()
            .child(BookingHour.childRefName)
            .observeEventType(FIRDataEventType.Value) {(snapshot: FIRDataSnapshot) -> Void in

                let values = snapshot.value as! [AnyObject]
                BookingHour.today = values
                    .enumerate()
                    .map({ BookingHour(index: $0.index, data: $0.element) })
                callback()
            }
    }

    class func unsubscribe() {
        if let ref = BookingHour.refHandle {
            getFirebaseRef().removeObserverWithHandle(ref)
        }
    }
}


