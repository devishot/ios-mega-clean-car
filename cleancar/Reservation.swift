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


class Reservation: FirebaseDataProtocol {
    static let childRefName: String = "reservations"
    static let timeToWashMinuteMultiplier: Int = 15

    let id: String
    let user: User
    let bookingHour: BookingHour
    let services: Services
    let dateCreated: NSDate

    var boxIndex: Int?
    var washer: Washer?
    var timeToWash: Int?


    init(id: String, user: User, bookingHour: BookingHour, services: Services) {
        self.id = id
        self.user = user
        self.bookingHour = bookingHour
        self.services = services
        self.dateCreated = NSDate()
    }

    init(data: AnyObject) {
        let parsed = JSON(data)
        self.id = parsed["id"].stringValue
        self.user = User(
            uid: parsed["user", "id"].stringValue,
            data: parsed["user"].object
        )

        print("here", BookingHour.today)
        
        self.bookingHour = BookingHour.today[parsed["booking_hour_index"].intValue]
        self.services = Services(data: parsed["services"].object)
        self.dateCreated = parseTime(parsed["date_created"].stringValue)

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
            "date_created": formatTime(dateCreated)
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

    static func create(carInfo: CarInfo, bookingHour: BookingHour,
                       services: Services,
                       completion: ()->(Void) ) -> Reservation {
        let user = User.getUser()!,
            ref = getFirebaseRef(),
            id = ref.child(Reservation.childRefName).childByAutoId().key

        /* //auto reserve - Part I
        let bookingData: [String: AnyObject] = bookingHour.reserve(),
            boxIndex = bookingData["boxIndex"] as! Int,
            washer = bookingData["washer"]! as! Washer,
            reservedBookingHours = bookingData["bookingHours"]! as! [BookingHour]
        */

        var updUser = user.update(carInfo)
        let reservation = Reservation(id: id, user: updUser, bookingHour: bookingHour, services: services)
        updUser = updUser.update(reservation)

        // collect requests
        let childUpdates: NSMutableDictionary = [
            "/\(Reservation.childRefName)/\(id)": reservation.toDict(),
            "/\(User.childRefName)/\(updUser.id)": updUser.toDictFull(),
            "/\(BookingHour.childRefName)/\(bookingHour.index)/unassigned/\(id)": true
        ]

        /* //auto reserve - Part II
        reservedBookingHours.forEach({ bh in
            childUpdates.setObject(
                bh.toDict(),
                forKey: "/\(BookingHour.childRefName)/\(bh.index)"
            )
        })
        */

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
            "\(Reservation.childRefName)/\(self.id)": NSNull(),
            "\(User.childRefName)/\(self.user.id)/current_reservation": NSNull(),
            "\(BookingHour.childRefName)/\(self.bookingHour.index)/unassigned/\(self.id)": NSNull()
        ]

        if self.boxIndex != nil {
            let prefix = "\(BookingHour.childRefName)/\(self.bookingHour)"
            updateChildValues.setObject(true,
                                        forKey: prefix+"/boxes/\(self.boxIndex!)")
            updateChildValues.setObject(true,
                                        forKey: prefix+"/washers/\(self.washer!.id)")
        }

        getFirebaseRef()
            .updateChildValues(updateChildValues as [NSObject: AnyObject])
    }
}

