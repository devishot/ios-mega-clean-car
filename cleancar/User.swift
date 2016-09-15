//
//  User.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON


class User: FirebaseDataProtocol {
    static let childRefName: String = "users"
    static var refHandle: FIRDatabaseHandle?

    static var current: User?

    let id: String
    let full_name: String
    var facebookProfile: [String: JSON]?
    var carInfo: CarInfo?
    var currentReservation: Reservation?

    init(uid: String, full_name: String) {
        self.id = uid
        self.full_name = full_name
    }

    init(uid: String, full_name: String, facebookProfile: [String: JSON]?,
         carInfo: CarInfo?, currentReservation: Reservation?) {
        self.id = uid
        self.full_name = full_name
        self.facebookProfile = facebookProfile
        self.carInfo = carInfo
        self.currentReservation = currentReservation
    }

    init(uid: String, data: AnyObject) {
        let parsed = JSON(data)

        self.id = uid
        self.full_name = parsed["full_name"].stringValue
        if let facebookProfile = parsed["facebook_profile"].dictionary {
            self.facebookProfile = facebookProfile
        }

        // optional
        if parsed["car_info"].isExists() {
            let data = parsed["car_info"].object
            self.carInfo = CarInfo(data: data)
        }
        if parsed["current_reservation"].isExists() {
            let data = parsed["current_reservation"],
                id = data["id"].stringValue

            self.currentReservation = Reservation(id: id, data: data.object)
        }
    }

    func toDict(withId: Bool = false) -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "full_name": self.full_name
        ]
        if withId {
            data.setObject(self.id, forKey: "id")
        }
        if self.carInfo != nil {
            data.setObject(self.carInfo!.toDict(), forKey: "car_info")
        }
        if self.facebookProfile != nil {
            data.setObject(toStringAnyObject(self.facebookProfile!),
                           forKey: "facebook_profile")
        }
        return data
    }

    func toDictFull() -> NSMutableDictionary {
        let data = self.toDict(false)
        if self.currentReservation != nil {
            data.setObject(self.currentReservation!.toDict(true),
                           forKey: "current_reservation")
        }
        return data
    }
    
    func getRefPrefix() -> String {
        return "\(User.childRefName)/\(self.id)"
    }



    func update(newReservation: Reservation) -> User {
        let copy = User(uid: id, full_name: full_name, facebookProfile: facebookProfile, carInfo: carInfo, currentReservation: currentReservation)
        copy.currentReservation = newReservation
        return copy
    }

    func update(newCarInfo: CarInfo) -> User {
        let copy = User(uid: id, full_name: full_name, facebookProfile: facebookProfile, carInfo: carInfo, currentReservation: currentReservation)
        copy.carInfo = newCarInfo
        return copy
    }


    // firebase:
    static func getUser() -> User? {
        if let auth = FIRAuth.auth() {
            let uid = auth.currentUser!.uid,
                full_name = auth.currentUser!.displayName!
            /*
            let facebookProfile = nil,
                carInfo = nil,
                currentReservation = nil
            */

            // TODO: fetch other data
            return User(uid: uid, full_name: full_name)
        }
        return nil
    }


    static func subscribeToCurrent(completion: ()->(Void)) -> Void {
        let uid = self.getUser()!.id
        User.refHandle = getFirebaseRef()
            .child(User.childRefName)
            .child(uid)
            .observeEventType(.Value, withBlock: { (snapshot) in
                //check is UserProfile exists
                if snapshot.value is NSNull {
                    // create UserProfile
                    User.saveCurrentUser(completion)
                } else {
                    // fetch BookingHours for Reservation inside parsed User
                    BookingHour.subscribeToToday({ () -> (Void) in
                        // Note: BookingHour.today - was setted
                        BookingHour.unsubscribe()

                        let user = User(uid: uid, data: snapshot.value!)
                        User.current = user
                        completion()
                    })
                }
            })
    }

    class func unsubscribe() {
        if let ref = User.refHandle {
            getFirebaseRef().removeObserverWithHandle(ref)
        }
    }

    static func saveCurrentUser(completion: () -> (Void)) -> Void {
        let user = User.getUser()!
        getFirebaseRef()
            .child(User.childRefName)
            .child(user.id)
            .setValue(user.toDict(), withCompletionBlock: {_,_ in
                User.current = user
                completion()
            })
    }


    static func logInByAccountKit(uid: String, phoneNumber: String, completion: () -> (Void) ) {
        let akEmail = "\(phoneNumber)@accountkit.fb",
            akPassword = uid

        FIRAuth.auth()?.signInWithEmail(akEmail, password: akPassword) { (user, error) in
            if error == nil { // done!
                self.afterLogin(completion)
                
            } else {
                print(".User.logInByAccountKit.error", error.debugDescription, akEmail, akPassword)
            }
        }
    }

    static func signUpWithAccountKit(uid: String, phoneNumber: String, fullName: String, completion: () -> (Void) ) {
        let akEmail = "\(phoneNumber)@accountkit.fb",
            akPassword = uid

        FIRAuth.auth()?.createUserWithEmail(akEmail, password: akPassword) { (user, error) in
            if  error == nil,
                let user = user {

                // set fullName
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = fullName
                changeRequest.commitChangesWithCompletion { err in
                    if err == nil { // done!
                        self.afterLogin(completion)

                    } else {
                        print(".User.signUpWithAccountKit.commitChangesWithCompletion.error", err.debugDescription, fullName)
                    }
                }
            } else {
                print(".User.signUpWithAccountKit.createUserWithEmail.error", error.debugDescription, akEmail, akPassword)

                // already exist:
                logInByAccountKit(uid, phoneNumber: phoneNumber, completion: completion)
            }
        }
    }
    
    

    static func logInByFacebook(completion: () -> (Void) ) -> Void {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);

        // fetch updated FacebookProfile data

        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if error == nil {
                print("Firebase login: \(user!.displayName!)");
                afterLogin(completion)
            } else {
                print("Error: while login into Firebase:", error.debugDescription);
            }
        }
    }

    static func isAlreadyLoggedInByFacebook(completion: () -> (Void) ) -> Bool {
        if FBSDKAccessToken.currentAccessToken() != nil {
            if let user = FIRAuth.auth()?.currentUser {
                print("Already logged in, user: \(user.displayName)");
                completion()
            } else {
                print("Warning: not logged in Firebase")
                // sign into Firebase
                User.logInByFacebook(completion)
            }
            return true
        }
        return false
    }

    static func afterLogin(completion: () -> (Void)) -> Void {
        // fetch or create UserProfile
        User.subscribeToCurrent(completion)
        // TODO: fetch FacebookProfile data and update UserProfile
    }

    static func logOut(completion: () -> (Void)) -> Void {
        do {
            // logout from Firebase
            try FIRAuth.auth()?.signOut()
            // logout from Facebook
            let facebookLogin = FBSDKLoginManager();
            facebookLogin.logOut()
            User.current = nil

            completion()

        } catch {
            print(error)
        }
    }

}