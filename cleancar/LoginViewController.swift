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


class LoginViewController: UIViewController {

    // IBOutlets
    @IBOutlet var signUpView: UIView!
    @IBOutlet var signInView: UIView!
    @IBOutlet weak var signUpNameField: UITextField!
    @IBOutlet weak var signUpNumberField: UITextField!
    @IBOutlet weak var signInNumberField: UITextField!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!


    // IBActions
    @IBAction func clickedFacebookLoginButton(sender: UIButton) {
        self.facebookLogin() {
            self.firebaseLogin(self.redirectToHome)
        }
    }
    @IBAction func clickedSignUpButton(sender: UIButton) {
        self.redirectToCheckNumber()
    }
    @IBAction func clickedSignInButton(sender: UIButton) {
        self.redirectToCheckNumber()
    }
    @IBAction func clickedRightBarButton(sender: UIBarButtonItem) {
        self.isLoginPage = !self.isLoginPage
        self.updateLoginPage()
    }


    // constants
    let loginCheckSegueID = "loginCheck"
    let homeSegueID = "homeDirect"
    let textSignIn = "Войти"
    let textSignUp = "Регистрация"

    
    // variables
    var isLoginPage = false


    override func viewDidLoad() {
        super.viewDidLoad()

        // style
     //   navigationController!.navigationBar.barTintColor = UIColor(red: 216.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0)

        // behaviour
        self.facebookAlreadyLoggedIn()
        // TODO: also add check for Already Firebase Auth
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginCheckSegueID {
            let destController = segue.destinationViewController as! LoginCheckViewController
            // collect fields value and set in controller
            
        }
    }


    func updateLoginPage() -> Void {
        if self.isLoginPage {
            rightBarButton.title = textSignUp
            UIView.transitionFromView(signUpView,
                                      toView: signInView,
                                      duration: 0.2,
                                      options: UIViewAnimationOptions.ShowHideTransitionViews,
                                      completion: nil)
        } else {
            rightBarButton.title = textSignIn
            UIView.transitionFromView(signInView,
                                      toView: signUpView,
                                      duration: 0.2,
                                      options: UIViewAnimationOptions.ShowHideTransitionViews,
                                      completion: nil)
        }
    }

    func redirectToCheckNumber() -> Void {
        if self.isLoginPage {
            
        } else {
            
        }
        performSegueWithIdentifier(loginCheckSegueID, sender: self)
    }

    func redirectToHome() -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier(self.homeSegueID, sender: self)
        }
    }


    func facebookAlreadyLoggedIn() -> Bool {
        if FBSDKAccessToken.currentAccessToken() != nil {
            if let user = FIRAuth.auth()?.currentUser {
                print("Already logged in, user: \(user.displayName)");
                self.redirectToHome()
            } else {
                print("Warning: not logged in Firebase")
                // sign into Firebase and redirect to Home
                self.firebaseLogin(redirectToHome)
            }
            return true
        }
        return false
    }

    func facebookLogin(completion: () -> (Void)) -> Void {
        let facebookLogin = FBSDKLoginManager();
        
        facebookLogin.logInWithReadPermissions(["email", "user_friends"], fromViewController: self) { (result, error) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                completion()
            } else {
                print("Error: while login via Facebook", error.debugDescription)
            }
            
        }
    }

    func firebaseLogin(completion: () -> (Void) ) -> Void {
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

}


