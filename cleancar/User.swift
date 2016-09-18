//
//  User.swift
//  cleancar
//
//  Created by MacBook Pro on 8/28/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import Firebase
import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON


enum UserRoles {
    case Owner
    case Admin
    case Client
}

enum UserErrors: ErrorType {
    case ProfileNotExist
    case ProfileAlreadyExist
    case NotLoggedIn
    case UnknowError
}


typealias CompletionWithError = (UserErrors?) -> (Void)



class User: FirebaseDataProtocol {
    static let childRefName: String = "users"
    static var refHandle: FIRDatabaseHandle?

    static var current: User?
    
    // AccountKit
    static var accountKit: AKFAccountKit = AKFAccountKit(responseType: .AccessToken)


    let id: String
    let full_name: String
    let role: UserRoles
    var facebookProfile: [String: JSON]?
    var accountKitProfile: [String: JSON]?
    var carInfo: CarInfo?
    var currentReservation: Reservation?


    init(uid: String, full_name: String) {
        self.id = uid
        self.full_name = full_name
        self.role = .Client
    }

    init(uid: String, data: AnyObject) {
        let parsed = JSON(data)

        self.id = uid
        self.full_name = parsed["full_name"].stringValue

        var role: UserRoles = .Client
        if parsed["is_admin"].bool != nil {
            role = .Admin
        }
        if parsed["is_owner"].bool != nil {
            role = .Owner
        }
        self.role = role

        if let facebookProfile = parsed["profile_facebook"].dictionary {
            self.facebookProfile = facebookProfile
        }
        if let accountkitProfile = parsed["profile_accountkit"].dictionary {
            self.accountKitProfile = accountkitProfile
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
        if self.role == .Admin {
            data.setObject(true, forKey: "is_admin")
        } else if self.role == .Owner {
            data.setObject(true, forKey: "is_owner")
        }

        if self.carInfo != nil {
            data.setObject(self.carInfo!.toDict(), forKey: "car_info")
        }
        if self.facebookProfile != nil {
            data.setObject(toStringAnyObject(self.facebookProfile!),
                           forKey: "profile_facebook")
        }
        if self.accountKitProfile != nil {
            data.setObject(toStringAnyObject(self.accountKitProfile!),
                           forKey: "profile_accountkit")
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

    static func subscribeToCurrent(completion: CompletionWithError) {
        let uid = self.getUser()!.id
        User.refHandle = getFirebaseRef()
            .child(User.childRefName)
            .child(uid)
            .observeEventType(.Value, withBlock: { (snapshot) in
                //check is UserProfile exists
                if snapshot.value is NSNull {
                    completion(UserErrors.ProfileNotExist)

                } else {
                    // fetch BookingHours for Reservation inside parsed User
                    BookingHour.subscribeToToday({ () -> (Void) in
                        // Note: BookingHour.today - was setted
                        BookingHour.unsubscribe()

                        let user = User(uid: uid, data: snapshot.value!)
                        User.current = user
                        completion(nil)
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


    // AcountKit
    static func fetchAccountKitData(completion: (uid: String, phoneNumber: String) -> (Void) ) {
        User.accountKit.requestAccount({ (account: AKFAccount?, error: NSError?) in
            let akID = account!.accountID
            let phoneNumber = account!.phoneNumber!.stringRepresentation()

            completion(uid: akID, phoneNumber: phoneNumber)
        })
    }

    static func signInByAccountKit(completion: CompletionWithError) {
        User.fetchAccountKitData({ id, phoneNumber in
            let akEmail = "\(phoneNumber)@accountkit.fb",
                akPassword = id

            FIRAuth.auth()?.signInWithEmail(akEmail, password: akPassword) { (user, error) in
                if error == nil { // done!
                    self.afterSignIn(completion)

                } else {
                    print(".User.logInByAccountKit.error", error.debugDescription, akEmail, akPassword)
                    completion(UserErrors.ProfileNotExist)
                }
            }
        })
    }

    static func signUpWithAccountKit(fullName: String, completion: CompletionWithError) {
        User.fetchAccountKitData({ id, phoneNumber in
            let akEmail = "\(phoneNumber)@accountkit.fb",
                akPassword = id

            FIRAuth.auth()?.createUserWithEmail(akEmail, password: akPassword) { (user, error) in
                if error == nil { // set fullName
                    let changeRequest = user!.profileChangeRequest()
                    changeRequest.displayName = fullName
                    changeRequest.commitChangesWithCompletion { err in
                        if err == nil { // done!
                            self.afterSignIn(completion)

                        } else {
                            completion(UserErrors.UnknowError)
                        }
                    }

                } else {
                    completion(UserErrors.ProfileAlreadyExist)

                }
            }
        })
    }


    // Facebook
    static func logInByFacebook(completion: CompletionWithError) {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString);

        // fetch updated FacebookProfile data

        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if error == nil {
                print("Firebase login: \(user!.displayName!)");
                afterSignIn(completion)
            } else {
                print("Error: while login into Firebase:", error.debugDescription);
            }
        }
    }

    static func isAlreadyLoggedInByFacebook(completion: CompletionWithError) -> Bool {
        if FBSDKAccessToken.currentAccessToken() != nil {
            if let user = FIRAuth.auth()?.currentUser {
                print("Already logged in, user: \(user.displayName)");
                afterSignIn(completion)
            } else {
                print("Warning: not logged in Firebase")
                // sign into Firebase
                User.logInByFacebook(completion)
            }
            return true
        }
        return false
    }

    static func isAlreadyLoggedIn(completion: CompletionWithError) {
        if FIRAuth.auth()?.currentUser != nil {
            afterSignIn(completion)
        } else {
            completion(UserErrors.NotLoggedIn)
        }
    }

    static func afterSignIn(completion: CompletionWithError) {
        // get or create UserProfile
        User.subscribeToCurrent({ userError in
            if userError == nil {
                completion(nil)
            } else if userError! == UserErrors.ProfileNotExist { // create UserProfile
                User.saveCurrentUser() {
                    completion(nil)
                    afterSignUp() { error in }
                }
            }
        })
    }

    static func afterSignUp(completion: CompletionWithError) {
        // 1. update profile by AccountKit
        User.fetchAccountKitData() { (akID, phoneNumber) in
            let data = [
                "id": akID,
                "phone_number": phoneNumber
            ]
            let user = User.getUser()!
            getFirebaseRef()
                .child(User.childRefName)
                .child(user.id)
                .child("profile_accountkit")
                .setValue(data)
        }

        // 2. TODO: update profile by Facebook
    }

    static func logOut(completion: () -> (Void)) {
        do {
            // logout from Firebase
            try FIRAuth.auth()?.signOut()
            // logout from Facebook
            let facebookLogin = FBSDKLoginManager();
            facebookLogin.logOut()
            // logout from AccountKit
            User.accountKit.logOut()

            User.current = nil
            completion()

        } catch {
            print(error)
        }
    }

}
