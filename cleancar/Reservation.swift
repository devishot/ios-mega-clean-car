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

    var boxIndex: Int?
    var washer: Washer?
    var timeToWash: Int?


    init(id: String, user: User, bookingHour: BookingHour, services: Services) {
        self.id = id
        self.user = user
        self.bookingHour = bookingHour
        self.services = services
        self.timestamp = NSDate()
        self.status = .NonAssigned
    }

    init(data: AnyObject) {
        let parsed = JSON(data)
        self.id = parsed["id"].stringValue
        self.user = User(
            uid: parsed["user", "id"].stringValue,
            data: parsed["user"].object
        )
        self.bookingHour = BookingHour.today[parsed["booking_hour_index"].intValue]
        self.services = Services(data: parsed["services"].object)
        self.timestamp = parseTimestamp(parsed["timestamp"].intValue)
        self.status = ReservationStatus(rawValue: parsed["status"].intValue)!

        // optional
        self.boxIndex = parsed["box_index"].int
        if let object: AnyObject = parsed["washer"].object {
            self.washer = Washer(data: object)
        }
        self.timeToWash = parsed["time_to_wash"].int
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
        if timeToWash != nil {
            data.setObject(timeToWash!, forKey: "time_to_wash")
        }
        if boxIndex != nil {
            data.setObject(boxIndex!, forKey: "box_index")
        }
        if washer != nil {
            data.setObject(washer!.toDict(true), forKey: "washer")
        }
        return data
    }

    // create as .NonAssigned
    static func create(carInfo: CarInfo, bookingHour: BookingHour,
                       services: Services,
                       completion: ()->(Void) ) -> Reservation {
        let user = User.getUser()!,
            ref = getFirebaseRef(),
            id = ref.child(Reservation.childRefName).childByAutoId().key

        var updUser = user.update(carInfo)
        let reservation = Reservation(id: id, user: updUser, bookingHour: bookingHour, services: services)
        updUser = updUser.update(reservation)

        // collect requests
        let childUpdates: NSMutableDictionary = [
            "/\(Reservation.childRefName)/\(reservation.status.rawValue)/\(id)": reservation.toDict(),
            "/\(User.childRefName)/\(updUser.id)": updUser.toDictFull(),
            "/\(BookingHour.childRefName)/\(bookingHour.index)/non_assigned/\(id)": true
        ]

        // push requests
        ref.updateChildValues(
            childUpdates as [NSObject: AnyObject],
            withCompletionBlock: {(error, ref) in
                completion()
            }
        )
        return reservation
    }

    func delete() {
        let updateChildValues: NSMutableDictionary = [
            "\(Reservation.childRefName)/\(self.status.rawValue)/\(self.id)": NSNull(),
            "\(User.childRefName)/\(self.user.id)/current_reservation": NSNull()
        ]

        if self.status.rawValue == ReservationStatus.NonAssigned.rawValue {
            updateChildValues.setObject(NSNull(),
                                        forKey: "\(BookingHour.childRefName)/\(self.bookingHour.index)/non_assigned/\(self.id)")
        } else {
            let prefix = "\(BookingHour.childRefName)/\(self.bookingHour)"
            updateChildValues.setObject(true,
                                        forKey: prefix+"/boxes/\(self.boxIndex!)")
            updateChildValues.setObject(true,
                                        forKey: prefix+"/washers/\(self.washer!.id)")
        }

        getFirebaseRef()
            .updateChildValues(updateChildValues as [NSObject: AnyObject])
    }

    static func subscribeTo(filterByStatus: ReservationStatus,
                     completion: (reservations: [Reservation])->Void) {
        let ref = getFirebaseRef()
            .child(Reservation.childRefName)
            .child(String(filterByStatus.rawValue))
            .observeEventType(.Value) { (snapshot: FIRDataSnapshot) -> Void in

                if snapshot.value is NSNull {
                    completion(reservations: [])
                    return
                }

                let data = JSON(snapshot.value!),
                    reservations = data.dictionaryObject!.map({ Reservation(data: $0.1) })

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

