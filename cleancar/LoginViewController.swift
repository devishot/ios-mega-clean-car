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
    @IBOutlet weak var facebookLoginButtonBorder: UIButton!
    @IBOutlet weak var signInButtonBorder: UIButton!
    @IBOutlet var backgroundView: UIView!


    // IBActions
    @IBAction func clickedFacebookLoginButton(sender: UIButton) {
        self.redirectToLoginPageOfFacebookAuth({ result, error in
            self.viewModel.onErrorWithFacebookManager(result, error: error)
        })
    }
    @IBAction func clickedSignInButton(sender: UIButton) {
        self.redirectToLoginPageOfAccountKit()
    }
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {
        let destController = segue.sourceViewController as! SignupSecondStepViewController
        let fullName = destController.textFieldFullName.text!

        print(".LoginVC.unwindSegue", fullName)
        self.viewModel.signUpByAccountKit(fullName)
    }


    var viewModel: AuthViewModel!


    // constants
    let homeSegueID = "homeDirect"
    let segueSignupSecondStep = "signupSecondStep"
    let segueActivityIndicator = "activityIndicatorID"


    // variables
    var _pendingLoginViewController: AKFViewController?
    var _authorizationCode: String?
    var activityIndicatorViewController: ActivityIndicatorViewController?
    var activityIndicatorDescriptionText: String?


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

        self.viewModel = AuthViewModel()
        self.viewModel.didRedirectToCompleteSignUp = {[weak self] _ in
            self?.redirectToCompleteSignUp()
        }
        self.viewModel.didRedirectToHome = {[weak self] _ in
            self?.redirectToHome()
        }
        self.viewModel.didUpdateNetworkActivityStatus = {[weak self] (active: Bool, status: String?, onError: String?, completeWithBlock: (() -> Void) ) in
            if active {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self?.showActivityIndicator(status)
            } else {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self?.hideActivityIndicator(completeWithBlock)
            }

            if let errorMessage = onError {
                self?.displayAlertMesage(errorMessage)
                return
            }
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        print(".LoginVC viewWillAppear", self.viewModel.isLoggedIn())

        if self.viewModel.isLoggedIn() {
            print(".LoginVC isLoggedIn")
            self.viewModel.afterLogin()

        } else {
            // is not logged in, yet
            // signIn/signUp by token, if exists
            if self.viewModel.isAvailableTokenOfAccountKit() {
                self.viewModel.loginByAccounKit()

            } else if self.viewModel.isAvailableTokenOfFacebookAuth() {
                self.viewModel.loginByFacebookAuth()

            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueActivityIndicator {
            let destController = segue.destinationViewController as! ActivityIndicatorViewController
            destController.textDescription = self.activityIndicatorDescriptionText
            self.activityIndicatorViewController = destController
        }
    }


    func redirectToHome() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.homeSegueID, sender: self)
        }
    }
    func redirectToCompleteSignUp() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.segueSignupSecondStep, sender: self)
        }
    }

    func showActivityIndicator(description: String?) -> Void {
        let display: (() -> Void) = {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier(self.segueActivityIndicator, sender: self)
            }
        }

        self.activityIndicatorDescriptionText = description
        // to update description we should call `prepareForSegue` again
        // by hiding and show it again
        if self.activityIndicatorViewController != nil {
            self.hideActivityIndicator() {
                display()
            }
        } else {
            display()

        }
    }
    func hideActivityIndicator( completion: (()->Void) ) -> Void {
        self.dismissViewControllerAnimated(false) {
            self.activityIndicatorViewController = nil
            completion()
        }
    }
    func displayAlertMesage(message: String) {
        User.logOut()

        let alert = UIAlertController(title: "«Хьюстон, у нас проблема» 🤕", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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

    func redirectToLoginPageOfAccountKit() {
        let preFillPhoneNumber: AKFPhoneNumber? = nil
        let inputState = NSUUID().UUIDString
        let vc: AKFViewController = User.accountKit.viewControllerForPhoneLoginWithPhoneNumber(preFillPhoneNumber, state: inputState) as! AKFViewController
        vc.enableSendToFacebook = true

        self.prepareLoginViewController(vc)
        self.presentViewController(vc as! UIViewController, animated: true, completion: nil)
    }
    // END: Facebook AccountKit

    func redirectToLoginPageOfFacebookAuth(onError: (result: FBSDKLoginManagerLoginResult, error: NSError?) -> Void) -> Void
    {
        let loginManager = FBSDKLoginManager();
        loginManager.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() == nil {
                onError(result: result, error: error)
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

