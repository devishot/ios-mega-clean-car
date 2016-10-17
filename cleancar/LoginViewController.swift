//
//  LoginViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 8/27/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import AccountKit


enum LoginViewControllerStates {
    case AfterSignupSecondStep
    case OnSignupSecondStep
    case OnSignin
    case OnHome
    case None
}


class LoginViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var facebookLoginButtonBorder: UIButton!
    @IBOutlet weak var signInButtonBorder: UIButton!
    @IBOutlet var backgroundView: UIView!


    // IBActions
    @IBAction func clickedFacebookLoginButton(sender: UIButton) {
        self.facebookLogin() {
            User.logInByFacebook() { userError in
                self.redirectToHome()
            }
        }
    }
    @IBAction func clickedSignInButton(sender: UIButton) {
        self.loginWithPhoneNumber()
    }
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
        let destController = segue.sourceViewController as! SignupSecondStepViewController
        let fullName = destController.textFieldFullName.text!

        self.navState = .AfterSignupSecondStep
        User.signUpWithAccountKit(fullName) { userError in
            self.redirectToHome()
        }
    }


    // constants
    let homeSegueID = "homeDirect"
    let segueSignupSecondStep = "signupSecondStep"


    // variables
    var navState: LoginViewControllerStates = .None
    var _pendingLoginViewController: AKFViewController?
    var _authorizationCode: String?


    override func viewDidLoad() {
        super.viewDidLoad()

        // рамки кнопки
        signInButtonBorder.layer.borderColor = UIColor.whiteColor().CGColor
        signInButtonBorder.layer.borderWidth = 1
        signInButtonBorder.layer.masksToBounds = true
        signInButtonBorder.layer.cornerRadius = 5

        facebookLoginButtonBorder.layer.cornerRadius = 5
        facebookLoginButtonBorder.layer.masksToBounds = true


        // init
        self.initAccountKit()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)


        // MARK: - if the user is already logged in

        // 1. into Firebase Auth
        User.isAlreadyLoggedIn() { userError in
            if userError == nil {
                print(".login.firebaseAuth")
                self.redirectToHome()
            }
        }

        // 2. using facebook account
        User.isAlreadyLoggedInByFacebook() { userError in
            if userError == nil {
                print(".login.facebookLogin")
                self.redirectToHome()
            }
        }

        // 3. currenlty logged into AccountKit
        if User.accountKit.currentAccessToken != nil {
            User.signInByAccountKit() { userError in
                if userError == nil {
                    print(".login.accountKit")
                    self.redirectToHome()
                } else if userError! == UserErrors.ProfileNotExist  {
                    self.redirectToSignupSecondStep()
                }
            }
            
        }


        // for AccountKit
        if (_pendingLoginViewController != nil) {
            //resume pending login (if any)
            self.prepareLoginViewController(_pendingLoginViewController!)
            self.presentViewController(_pendingLoginViewController as! UIViewController, animated: true, completion: nil)
            _pendingLoginViewController = nil;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func redirectToHome() -> Void {
        if self.navState == .OnHome {
            return
        }

        self.navState = .OnHome
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.homeSegueID, sender: self)
        }
    }

    func redirectToSignupSecondStep() -> Void {
        self.navState = .OnSignupSecondStep
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.segueSignupSecondStep, sender: self)
        }
    }


    // MARK: Facebook AccountKit
    func initAccountKit() {
        _pendingLoginViewController = User.accountKit.viewControllerForLoginResume() as? AKFViewController
        _pendingLoginViewController?.delegate = self
    }

    func prepareLoginViewController(loginViewController: AKFViewController) {
        loginViewController.delegate = self
        loginViewController.advancedUIManager = nil
        loginViewController.defaultCountryCode = "KZ"

        //Costumize the theme
        let theme:AKFTheme = AKFTheme.defaultTheme()
        let purpleBgColor = UIColor(red:0.11, green:0.04, blue:0.21, alpha:0.8)
        let whiteColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)

        theme.headerBackgroundColor = purpleBgColor

        theme.headerTextColor = whiteColor
        theme.iconColor = whiteColor

        theme.statusBarStyle = .Default
        theme.textColor =  whiteColor
        theme.titleColor = whiteColor
        theme.backgroundColor = purpleBgColor
        theme.inputBorderColor =  whiteColor
        theme.inputBackgroundColor = purpleBgColor
        theme.inputTextColor =  whiteColor
        theme.buttonBackgroundColor = purpleBgColor
        theme.buttonBorderColor = whiteColor
        theme.buttonTextColor = whiteColor
        
        loginViewController.theme = theme
    }

    func loginWithPhoneNumber() {
        let preFillPhoneNumber: AKFPhoneNumber? = nil
        let inputState = NSUUID().UUIDString
        let vc: AKFViewController = User.accountKit.viewControllerForPhoneLoginWithPhoneNumber(preFillPhoneNumber, state: inputState) as! AKFViewController
        vc.enableSendToFacebook = true

        self.prepareLoginViewController(vc)
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
    }
    // END: Facebook AccountKit



    func facebookLogin(completion: () -> (Void)) -> Void {
        let loginManager = FBSDKLoginManager();

        loginManager.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                completion()
            } else {
                print("Error: while login via Facebook")
            }

        }
    }

}

extension LoginViewController: AKFViewControllerDelegate {
    func viewController(viewController: UIViewController!, didFailWithError error: NSError!) {
        print("error \(error)")
    }

    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        print(".AccountKit.didCompleteLoginWithAccessToken: \(accessToken.tokenString) state \(state)")
    }

    func viewController(viewController: UIViewController!, didCompleteLoginWithAuthorizationCode code: String!, state: String!) {
        print("..LoginWithAuthorizationCode", code, state)
    }
}

