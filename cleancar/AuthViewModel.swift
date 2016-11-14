//
//  AuthViewModel.swift
//  cleancar
//
//  Created by MacBook Pro on 11/13/16.
//
//

import Foundation
import Firebase
import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON


class AuthViewModel {
    
    
    // updates
    var didRedirectToCompleteSignUp: (() -> Void)?
    var didRedirectToHome: (() -> Void)?
    var didUpdateNetworkActivityStatus: ((active: Bool, status: String?, onError: String?, completeWithBlock: () -> Void) -> Void)?

    // inputs
    func onErrorWithFacebookManager(result: FBSDKLoginManagerLoginResult, error: NSError?) {
        //print(".AuthVM.FacebookManager.error", result.isCancelled, error?.localizedDescription)
        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка с Facebook") {}
    }

    
    // state variables
    var isWaitingSignUpByAccountKitFunc: Bool = false


    // helpers
    func isLoggedIn() -> Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
    func isAvailableTokenOfAccountKit() -> Bool {
        return User.accountKit.currentAccessToken != nil
    }
    func isAvailableTokenOfFacebookAuth() -> Bool {
        return FBSDKAccessToken.currentAccessToken() != nil
    }
    func loginByFacebookAuth() {
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)

        self.didUpdateNetworkActivityStatus?(active: true, status: "Выполняется вход", onError: nil) {}
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            if error == nil {
                self.didUpdateNetworkActivityStatus?(active: true, status: "Поиск профиля в базе приложения", onError: nil) {}
                User.isProfileExists() { exists in
                    if exists {
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {
                            self.afterLogin()
                        }

                    } else {
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {}
                        self.createProfileUsingFacebook()

                    }
                }

            } else {
                //print(".AuthMV.loginByFacebookAuth.error", error.debugDescription)
                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при входе используя Facebook") {}
            }
        }
    }
    func loginByAccounKit() {
        if self.isWaitingSignUpByAccountKitFunc {
            // do nothing when
            return
        }

        //print(".AuthVM.loginByAccounKit", "Загружаем ваш сотовый номер")
        self.didUpdateNetworkActivityStatus?(active: true, status: "Загружаем ваш сотовый номер", onError: nil) {}
        self.fetchAccountKitData(
            { id, phoneNumber in
                let akEmail = "\(phoneNumber)@accountkit.fb"
                let akPassword = id

                //print(".AuthVM.loginByAccounKit", "Поиск профиля в базе приложения")
                self.didUpdateNetworkActivityStatus?(active: true, status: "Поиск профиля в базе приложения", onError: nil) {}
                FIRAuth.auth()?.signInWithEmail(akEmail, password: akPassword) { (user, error) in
                    if error == nil { // done!
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {
                            self.afterLogin()
                        }

                    } else {
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {                             self.didRedirectToCompleteSignUp?()
                        }

                    }
                }

            }, onError: { error in
                //print(".AuthVM.loginByAccounKit.error", error)
                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при получении сотового номера") {}
        })
    }
    func signUpByAccountKit(fullName: String) {
        self.isWaitingSignUpByAccountKitFunc = true

        //print(".AuthVM.signUpByAccountKit", "Загружаем ваш сотовый номер")
        self.didUpdateNetworkActivityStatus?(active: true, status: "Загружаем ваш сотовый номер", onError: nil) {}
        self.fetchAccountKitData(
            { id, phoneNumber in
                let akEmail = "\(phoneNumber)@accountkit.fb"
                let akPassword = id

                //print(".AuthVM.signUpByAccountKit", "Регистрация в базе данных")
                self.didUpdateNetworkActivityStatus?(active: true, status: "Регистрация в базе данных", onError: nil) {}
                FIRAuth.auth()?.createUserWithEmail(akEmail, password: akPassword) { (user, error) in
                    if error == nil {

                        // set fullName for Firebase Auth
                        self.didUpdateNetworkActivityStatus?(active: true, status: "Регистрация в базе — еще чуть-чуть", onError: nil) {}
                        let changeRequest = user!.profileChangeRequest()
                        changeRequest.displayName = fullName
                        changeRequest.commitChangesWithCompletion { err in
                            if err == nil {
                                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {}

                                // create Profile in Firebase Database
                                let data: JSON = [
                                    "id": id,
                                    "phone_number": phoneNumber
                                ]
                                self.createProfile(.AccountKit, providerData: data)

                            } else {
                                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при добавлении ФИО в базу") {}
                            }
                            self.isWaitingSignUpByAccountKitFunc = false
                        }

                    } else {
                        // completion(UserErrors.ProfileAlreadyExist)
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка регистрации: данный аккаунт существует") {}
                        self.isWaitingSignUpByAccountKitFunc = false
                    }
                }

            }, onError: { error in
                print(".AuthVM.signUpByAccountKit.error", error)
                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при получении сотового номера") {}
                self.isWaitingSignUpByAccountKitFunc = false
        })
    }

    func createProfile(provider: AuthProviderTypes, providerData: JSON) {
        //print(".AuthMV.createProfile", provider, providerData)
        let auth = FIRAuth.auth()!
        let firID = auth.currentUser!.uid
        let full_name = auth.currentUser!.displayName!

        let user = User.init(uid: firID, full_name: full_name)
        switch provider {
        case .AccountKit:
            user.accountKitProfile = providerData.dictionaryValue
        case .Facebook:
            user.facebookProfile = providerData.dictionaryValue
        }

        //print(".AuthVM.createProfile", "Создание профиля")
        self.didUpdateNetworkActivityStatus?(active: true, status: "Создание профиля", onError: nil) {}
        getFirebaseRef()
            .child(User.childRefName)
            .child(user.id)
            .setValue(user.toDict(), withCompletionBlock: { error, _ in
                if error == nil {
                    self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {}
                    print(".AuthVM.createProfile.done")
                    self.afterLogin()

                } else {
                    self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при создании профиля") {}
                }
            })
    }
    func createProfileUsingFacebook() {
        //print(".AuthMV.createProfileUsingFacebook")
        self.didUpdateNetworkActivityStatus?(active: true, status: "Запрос в Facebook", onError: nil) {}
        self.fetchFacebookAuthData(
            { data in
                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {}
                self.createProfile(.Facebook, providerData: data)

            }, onError: { error in
                self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при обращении к Facebook") {}
        })
    }

    func fetchAccountKitData(
        completion: (uid: String, phoneNumber: String) -> Void,
        onError: (error: NSError) -> Void
        ) {
        User.accountKit.requestAccount({ (account: AKFAccount?, error: NSError?) in
            if error != nil {
                onError(error: error!)
                return
            }
            
            let akID = account!.accountID
            let phoneNumber = account!.phoneNumber!.stringRepresentation()
            completion(uid: akID, phoneNumber: phoneNumber)
        })
    }
    func fetchFacebookAuthData(
        completion: (data: JSON) -> Void,
        onError: (error: NSError) -> Void
        ) {
        FBSDKGraphRequest
            .init(graphPath: "me", parameters: ["fields": "id, name, gender, age_range, link"])
            .startWithCompletionHandler({ (connection, result, error) -> Void in
                if error == nil {
                    completion(data: JSON(result))
                    
                } else {
                    onError(error: error)
                }
            })
    }
    
    
    func afterLogin() {
        print(".AuthMV.afterLogin")
        // 1. fetch Washers.all, will used by Booking.today
        // 2. fetch Booking.today or will create it
        // 3. fetch User.current, will use Booking.today inside currentResevation initializer
        // 4. fetch Firebase Remote Configs
        // 5. navigate to Home page

        typealias pipelineFunction = ((completion: ()->Void) -> Void)

        var firstAction: pipelineFunction
        var secondAction: pipelineFunction
        var thirdAction: pipelineFunction
        var fourthAction: pipelineFunction


        firstAction = { (completion: ()->Void) in
            self.didUpdateNetworkActivityStatus?(active: true, status: "Загрузка данных автомойки", onError: nil) {}
            Washer.fetchData() {
                BookingHour.fetchData() {
                    self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {
                        completion()
                    }
                }
            }
        }

        secondAction = { (completion: ()->Void) in
            self.didUpdateNetworkActivityStatus?(active: true, status: "Загрузка профиля", onError: nil) {}
            let uid = User.getFirebaseID()
            getFirebaseRef()
                .child(User.childRefName)
                .child(uid)
                .observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    //check is UserProfile exists
                    if snapshot.exists() {
                        let user = User(uid: uid, data: snapshot.value!)
                        User.current = user
                        //print(".AuthVM.afterLogin set User.current", User.current)
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: nil) {
                            completion()
                        }

                    } else {
                        self.didUpdateNetworkActivityStatus?(active: false, status: nil, onError: "Ошибка при загрузке профиля") {}
                    }
            })
        }

        thirdAction = { (completion: ()->Void) in
            // TODO
            completion()
        }

        fourthAction = { (completion: ()->Void) in
            self.didRedirectToHome?()
        }


        // run pipeline functions
        firstAction() {
            //print(".AuthVM.afterLogin – firstAction")
            secondAction() {
                //print(".AuthVM.afterLogin – secondAction")
                thirdAction() {
                    //print(".AuthVM.afterLogin – thirdAction")
                    fourthAction() {}
                }
            }
        }

    }


}


