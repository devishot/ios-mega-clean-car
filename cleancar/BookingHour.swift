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
    static let boxesCount: Int = 6

    static var today: [BookingHour] = [] {
        didSet {
            let startHour = 9
            var offsetBookingHourIndexes: Int = (getCurrentHour() - startHour + 1) * 60 / BookingHour.minuteMultiplier - (60 - getCurrentMinute()) / BookingHour.minuteMultiplier
            offsetBookingHourIndexes = max(0, offsetBookingHourIndexes)

            BookingHour.fromNow = BookingHour.today
                .filter({ $0.index >= offsetBookingHourIndexes })
        }
    }
    static var fromNow: [BookingHour] = []

    var index: Int
    var boxes: [Bool]
    var washers: [String: Bool]
    var nonAssignedReservationIds: [String]


    init(index: Int, data: AnyObject) {
        let parsed = JSON(data)

        self.index = index
        self.boxes = parsed["boxes"].arrayValue.map {$0.boolValue}
        self.washers = toStringBool(parsed["washers"].dictionaryValue)

        self.nonAssignedReservationIds = []
        if let non_assigned = parsed["non_assigned"].dictionary {
            self.nonAssignedReservationIds = non_assigned
                .filter({ $0.1.boolValue })
                .map({ $0.0 })
        }
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


    func getRefPrefix() -> String {
        return "\(BookingHour.getTodayChildRef())/\(self.index)"
    }

    func getHour() -> String {
        let addingMinutes = self.index * BookingHour.minuteMultiplier

        // 09:00
        let startHour = 9
        let startMinute = 0
        // 09:00 + 150 minute = 11:30
        let hour = startHour + (startMinute + addingMinutes) / 60
        let minute = (startMinute + addingMinutes) % 60

        func f(x: Int) -> String {
            return (x < 10) ?  "0\(x)" : "\(x)"
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


    static func getByIndex(index: Int) -> BookingHour {
        return BookingHour.today[index]
    }

    class func initToday(completion: () -> (Void)) {
        let startHour = 9,
        endHour = 21,
        bookingHoursCount = (endHour - startHour) * 60 / BookingHour.minuteMultiplier
        
        let boxes = (0..<BookingHour.boxesCount).map({_ in true })
        let washers = NSMutableDictionary()
        Washer.all.forEach() { (id, washer) in washers.setObject(true, forKey: id) }

        let initData = (0..<bookingHoursCount).generate()
            .map({index in ["boxes": boxes, "washers": washers] })

        getFirebaseRef()
            .child(BookingHour.getTodayChildRef())
            .setValue(initData, withCompletionBlock: {_ in completion()})
    }

    class func getTodayChildRef() -> String {
        let todaystampt = formatAsString(NSDate(), onlyDate: true)
        return "\(BookingHour.childRefName)/\(todaystampt)"
    }


    // firebase
    class func subscribeToToday(callback: () -> (Void) ) {
        BookingHour.refHandle = getFirebaseRef()
            .child(BookingHour.getTodayChildRef())
            .observeEventType(FIRDataEventType.Value) {(snapshot: FIRDataSnapshot) -> Void in

                if snapshot.value is NSNull {
                    BookingHour.initToday() {
                        BookingHour.subscribeToToday(callback)
                    }
                    return
                }

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


