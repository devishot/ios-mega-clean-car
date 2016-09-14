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


class LoginViewController: UIViewController {

    // IBOutlets


    // IBActions
    @IBAction func clickedFacebookLoginButton(sender: UIButton) {
        self.facebookLogin() {
            User.logInByFacebook(self.redirectToHome)
        }
    }
    @IBAction func clickedSignInButton(sender: UIButton) {
        self.loginWithPhoneNumber()
    }

    @IBOutlet weak var facebookLoginButtonBorder: UIButton!
    @IBOutlet weak var signInButtonBorder: UIButton!


    // constants
    let homeSegueID = "homeDirect"

    
    // variables
    var isLoginPage = false
    
    var _accountKit: AKFAccountKit!
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


        // check exist Login credentials for:
        // 1. facebook account
        User.isAlreadyLoggedInByFacebook(self.redirectToHome)

        // 2. phone number AccountKit
        if _accountKit == nil {
            _accountKit = AKFAccountKit(responseType: .AuthorizationCode)
        }
        _pendingLoginViewController = _accountKit.viewControllerForLoginResume() as? AKFViewController
        _pendingLoginViewController?.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if  _accountKit.currentAccessToken != nil {
            //if the user is already logged in, go to the main screen

            // TODO: firebaseLogin()

        } else if (_pendingLoginViewController != nil) {
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
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.homeSegueID, sender: self)
        }
    }


    // MARK: Facebook AccountKit
    func prepareLoginViewController(loginViewController: AKFViewController) {
        loginViewController.delegate = self
        loginViewController.advancedUIManager = nil
        loginViewController.defaultCountryCode = "KZ"

        //Costumize the theme
        let theme:AKFTheme = AKFTheme.defaultTheme()
        theme.headerBackgroundColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
        theme.headerTextColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        theme.iconColor = UIColor(red: 0.325, green: 0.557, blue: 1, alpha: 1)
        theme.inputTextColor = UIColor(white: 0.4, alpha: 1.0)
        theme.statusBarStyle = .Default
        theme.textColor = UIColor(white: 0.3, alpha: 1.0)
        theme.titleColor = UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1)

        loginViewController.theme = theme
    }

    func loginWithPhoneNumber() {
        let preFillPhoneNumber: AKFPhoneNumber? = nil
        let inputState = NSUUID().UUIDString
        let vc: AKFViewController = _accountKit.viewControllerForPhoneLoginWithPhoneNumber(preFillPhoneNumber, state: inputState) as! AKFViewController
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
                print("Error: while login via Facebook", error.debugDescription)
            }
            
        }
    }

}

extension LoginViewController: AKFViewControllerDelegate {
    func viewController(viewController: UIViewController!, didFailWithError error: NSError!) {
        print("error \(error)")
    }
    func viewController(viewController: UIViewController!, didCompleteLoginWithAccessToken accessToken: AKFAccessToken!, state: String!) {
        print("did complete login with access token \(accessToken.tokenString) state \(state)")
    }
}

