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


class User: FirebaseDataProtocol {
    static let childRefName: String = "users"

    let id: String
    let full_name: String
    var facebookProfile: [String: String]?
    var carInfo: CarInfo?
    var currentReservation: Reservation?

    init(uid: String, full_name: String) {
        self.id = uid
        self.full_name = full_name
    }

    init(uid: String, full_name: String, facebookProfile: [String: String]?,
         carInfo: CarInfo?, currentReservation: Reservation?) {
        self.id = uid
        self.full_name = full_name
        self.facebookProfile = facebookProfile
        self.carInfo = carInfo
        self.currentReservation = currentReservation
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


    func toDict(withId: Bool = false) -> NSMutableDictionary {
        let data: NSMutableDictionary = [
            "full_name": self.full_name
        ]
        if withId {
            data.setObject(self.id, forKey: "id")
        }
        if self.carInfo != nil {
            data.setObject(self.carInfo!.toDict(), forKey: "carInfo")
        }
        if self.facebookProfile != nil {
            data.setObject(self.facebookProfile!, forKey: "facebookProfile")
        }
        if self.currentReservation != nil {
            data.setObject(self.currentReservation!.id,
                           forKey: "currentReservationId")
        }
        return data
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

    static func logInByFacebook(completion: () -> (Void) ) -> Void {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if error == nil {
                print("Firebase login: \(user?.displayName)");
                completion()
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

    
    static func logOut(completion: () -> (Void)) -> Void {
        do {
            // logout from Firebase
            try FIRAuth.auth()?.signOut()
            // logout from Facebook
            let facebookLogin = FBSDKLoginManager();
            facebookLogin.logOut()
            
            completion()

        } catch {
            print(error)
        }
    }

}