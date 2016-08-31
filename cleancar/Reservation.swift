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

    var boxIndex: Int?
    var washer: Washer?
    var timeToWash: Int?


    init(id: String, user: User, bookingHour: BookingHour, services: Services) {
        self.id = id
        self.user = user
        self.bookingHour = bookingHour
        self.services = services
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
            "services": services.toDict()
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

        // create Reservation
        let reservation = Reservation(id: id, user: user, bookingHour: bookingHour, services: services)

        // update User data
        var updUser = user.update(carInfo)
        updUser = updUser.update(reservation)

        // collect requests
        let childUpdates: NSMutableDictionary = [
            "/\(Reservation.childRefName)/\(id)": reservation.toDict(),
            "/\(User.childRefName)/\(updUser.id)": updUser.toDictFull(),
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
        ref.updateChildValues(childUpdates as [NSObject: AnyObject],
                              withCompletionBlock: {(error, ref) in
            completion()
        })
        return reservation
    }
}
