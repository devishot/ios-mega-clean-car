//
//  Reservation.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON



enum ReservationStatus: Int {
    case NonAssigned
    case Assigned
    case Completed
    case FeedbackReceived
    case Declined
}



class Reservation: FirebaseDataProtocol {
    static let childRefName: String = "reservations"
    static var refHandle: FIRDatabaseHandle?
    static let timeToWashMinuteMultiplier: Int = 15

    let id: String
    let user: User
    let bookingHour: BookingHour
    let services: Services
    let timestamp: NSDate
    var status: ReservationStatus

    // when Assigned
    var boxIndex: Int?
    var washer: Washer?
    var timeToWash: Int?
    // when FeedbackReceived
    var feedbackRate: Int?
    var feedbackMessage: String?


    init(id: String, user: User, bookingHour: BookingHour, services: Services) {
        self.id = id
        self.user = user
        self.bookingHour = bookingHour
        self.services = services
        self.timestamp = NSDate()
        self.status = .NonAssigned
    }

    init(id: String, data: AnyObject) {
        let parsed = JSON(data)
        self.id = id
        self.user = User(
            uid: parsed["user", "id"].stringValue,
            data: parsed["user"].object
        )
        self.bookingHour = BookingHour.getByIndex(parsed["booking_hour_index"].intValue)
        self.services = Services(data: parsed["services"].object)
        self.timestamp = parseTimestamp(parsed["timestamp"].intValue)
        self.status = ReservationStatus(rawValue: parsed["status"].intValue)!

        // optional
        self.boxIndex = parsed["box_index"].int
        if let object: AnyObject = parsed["washer"].object {
            self.washer = Washer(data: object)
        }
        self.timeToWash = parsed["time_to_wash"].int
        self.feedbackRate = parsed["feedback_rate"].int
        self.feedbackMessage = parsed["feedback_message"].string
    }

    func toDict(withId: Bool = false) -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "user": user.toDict(true),
            "booking_hour_index": bookingHour.index,
            "services": services.toDict(),
            "timestamp": formatAsTimestamp(timestamp),
            "status": status.rawValue
        ]
        if withId {
            data.setObject(self.id, forKey: "id")
        }

        let optionalFields: [String: AnyObject?] = [
            "time_to_wash": timeToWash,
            "box_index": boxIndex,
            "washer": washer?.toDict(true),
            "feedback_rate": feedbackRate,
            "feedback_message": feedbackMessage
        ]
        optionalFields.forEach({ (key, value) in
            if value != nil {
                data.setObject(value!, forKey: key)
            }
        })

        return data
    }

    func isAssigned() -> Bool {
        return !self.isDeclined() &&
            self.status.rawValue > ReservationStatus.NonAssigned.rawValue
    }

    func isDeclined() -> Bool {
        return self.status.rawValue == ReservationStatus.Declined.rawValue
    }

    func isCompleted() -> Bool {
        return self.status.rawValue == ReservationStatus.Completed.rawValue
    }


    func getRefPrefix() -> String {
        return self.getRefPrefix(self.status)
    }

    func getRefPrefix(status: ReservationStatus) -> String {
        return "\(Reservation.childRefName)/\(status.rawValue)/\(self.id)"
    }

    
    func getBoxIndexText() -> String {
        return "#\(self.boxIndex! + 1)"
    }

    func getFeedbackRateVisual() -> String {
        let filled = (1...self.feedbackRate!).generate()
                .map({ _ in "\u{2605}" })
                .joinWithSeparator("")
        let empty = (self.feedbackRate!+1..<6).generate()
                .map({ _ in "\u{2606}" })
                .joinWithSeparator("")
        return filled + empty
    }

    // create in .NonAssigned
    static func create(carInfo: CarInfo, bookingHour: BookingHour,
                       services: Services,
                       completion: ()->(Void) ) -> Reservation {
        let user = User.getUser()!,
            ref = getFirebaseRef(),
            id = ref
                .child(Reservation.childRefName + String(ReservationStatus.NonAssigned.rawValue))
                .childByAutoId().key

        var updUser = user.update(carInfo)
        let reservation = Reservation(id: id, user: updUser, bookingHour: bookingHour, services: services)
        updUser = updUser.update(reservation)

        // collect requests
        let childUpdates: NSMutableDictionary = [
            reservation.getRefPrefix(): reservation.toDict(),
            updUser.getRefPrefix(): updUser.toDictFull(),
            "/\(bookingHour.getRefPrefix())/non_assigned/\(id)": true
        ]

        // push requests
        ref.updateChildValues(
            childUpdates as [NSObject: AnyObject],
            withCompletionBlock: {(error, ref) in completion() }
        )
        return reservation
    }

    func setDeclined(completion: () -> (Void)) {
        // 1. move to /reservations/[Declined.rawValue]/[id]
        // Note: don't change {status} field
        // 2. remove {current_reservation} at User
        // 3a. remove from {non_assigned} at BookingHour
        // 3b. set free {boxes} and {washers} at BookingHour
        let prefixB = self.bookingHour.getRefPrefix()

        let updateChildValues: NSMutableDictionary = [
            self.getRefPrefix(): NSNull(),
            self.getRefPrefix(.Declined): self.toDict(),
            "\(self.user.getRefPrefix())/current_reservation": NSNull()
        ]

        if self.isAssigned() {
            updateChildValues
                .setObject(true, forKey: prefixB+"/boxes/\(self.boxIndex!)")
            updateChildValues
                .setObject(true, forKey: prefixB+"/washers/\(self.washer!.id)")
        } else {
            updateChildValues
                .setObject(NSNull(), forKey: prefixB+"/non_assigned/\(self.id)")
        }

        getFirebaseRef()
            .updateChildValues(
                updateChildValues as [NSObject: AnyObject],
                withCompletionBlock: {_,_ in completion() }
            )
    }

    func setAssigned(boxIndex: Int, washer: Washer, timeToWash: Int,
                     completion: () -> (Void)) {
        let updateChildValues = NSMutableDictionary(),
            prevStatus = self.status,
            wasNonAssigned = !self.isAssigned()

        self.boxIndex = boxIndex
        self.washer = washer
        self.timeToWash = timeToWash
        self.status = ReservationStatus.Assigned

        if wasNonAssigned {
            updateChildValues
                .setObject(NSNull(), forKey: self.getRefPrefix(prevStatus))

            let prefixB = self.bookingHour.getRefPrefix()
            updateChildValues
                .setObject(NSNull(), forKey: prefixB+"/non_assigned/\(self.id)")
            updateChildValues
                .setObject(false, forKey: prefixB+"/boxes/\(boxIndex)")
            updateChildValues
                .setObject(false, forKey: prefixB+"/washers/\(washer.id)")
        }
        updateChildValues.setObject(self.toDict(), forKey: self.getRefPrefix())

        getFirebaseRef()
            .updateChildValues(
                updateChildValues as [NSObject: AnyObject],
                withCompletionBlock: {_,_ in completion() }
            )
    }

    func setCompleted(completion: () -> (Void)) {
        // move Reservation 
        // update {current_reservation} at User
        // update Statistic
        let prevStatus = self.status
        self.status = .Completed

        let updateChildValues: [NSObject: AnyObject] = [
            self.getRefPrefix(prevStatus): NSNull(),
            self.getRefPrefix(): self.toDict(),
            "\(self.user.getRefPrefix())/current_reservation": self.toDict(true)
        ]
        getFirebaseRef().updateChildValues(updateChildValues, withCompletionBlock: {_,_ in
            self.updateStatistic()
            completion()
        })
    }

    func setFeedbackReceived(rate: Int, message: String, completion: () -> (Void)) {
        // move Reservation
        // remove {current_reservation} at User
        // update Statistic

        let prevStatus = self.status
        self.status = .FeedbackReceived
        self.feedbackRate = rate
        self.feedbackMessage = message

        let updateChildValues: [NSObject: AnyObject] = [
            self.getRefPrefix(prevStatus): NSNull(),
            self.getRefPrefix(): self.toDict(),
            "\(self.user.getRefPrefix())/current_reservation": NSNull()
        ]
        getFirebaseRef()
            .updateChildValues(updateChildValues, withCompletionBlock: {_,_ in
                self.updateStatistic(true)
                completion()
            })
    }


    func updateStatistic(onlyRate: Bool = false) {
        let now = NSDate(),
            paths = [
                getStaticKey(now, forFilter: .Year),
                getStaticKey(now, forFilter: .Month),
                getStaticKey(now, forFilter: .Week),
                getStaticKey(now, forFilter: .Day)
            ]


        var newInfo: [String: AnyObject] = [
            "count": 1,
            "sum": self.services.getCostForTotal(),
            "rate_count": 0,
            "rate_sum": 0
        ]
        if onlyRate {
            newInfo = [
                "count": 0,
                "sum": 0,
                "rate_count": 1,
                "rate_sum": self.feedbackRate!
            ]
        }

        func updateInfo(data: [String: AnyObject]) -> [String: AnyObject] {
            let info = JSON(data).dictionaryValue
            return [
                "count": info["count"]!.intValue + (newInfo["count"]! as! Int),
                "sum": info["sum"]!.intValue + (newInfo["sum"]! as! Int),
                "rate_count": info["rate_count"]!.intValue + (newInfo["rate_count"]! as! Int),
                "rate_sum": info["rate_sum"]!.intValue + (newInfo["rate_sum"]! as! Int)
            ]
        }

        paths.forEach({ path in
            getFirebaseRef()
                .child("statistics" + path)
                .runTransactionBlock({ (currentState: FIRMutableData) -> FIRTransactionResult in

                    if currentState.hasChildren() {
                        let currentInfo = currentState.value! as! [String: AnyObject]
                        currentState.value = updateInfo(currentInfo)
                    } else {
                        currentState.value = newInfo
                    }
                    return FIRTransactionResult.successWithValue(currentState)
                })
        })
    }

    static func subscribeTo(filterByStatus: ReservationStatus,
                     completion: (reservations: [Reservation])->Void) {
        let ref = getFirebaseRef()
            .child(Reservation.childRefName + "/\(filterByStatus.rawValue)")
            .observeEventType(.Value) { (snapshot: FIRDataSnapshot) -> Void in

                if snapshot.value is NSNull {
                    completion(reservations: [])
                    return
                }

                let data = JSON(snapshot.value!),
                    reservations = data.dictionaryObject!.map({ Reservation(id: $0.0, data: $0.1) })

                completion(reservations: reservations)
            }
        Reservation.refHandle = ref
    }

    static func unsubscribe() {
        if let ref = Reservation.refHandle {
            getFirebaseRef().removeObserverWithHandle(ref)
        }
    }
}

