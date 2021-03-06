//
//  AppDelegate.swift
//  cleancar
//
//  Created by Aigerim'sMac on 17.08.16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit


let AppFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: "Helvetica Neue"])
let AppFontDescriptorLight = AppFontDescriptor.fontDescriptorByAddingAttributes([ UIFontDescriptorFaceAttribute: "Light"])


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // Firebase
        FIRApp.configure()

        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application,didFinishLaunchingWithOptions:launchOptions)

        //tab bar item color
        let font = UIFont(descriptor: AppFontDescriptorLight, size: 14)
        let attrsForNormal = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: font
        ]
        let attrsForSelected = [
            NSForegroundColorAttributeName: UIColor.ccPurpleSuperLight(),
            NSFontAttributeName: font
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attrsForNormal, forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsForSelected, forState: .Selected)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBar.appearance().barTintColor = UIColor.ccPurpleDark()

        //status bar
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        //ui window color 
        let win:UIWindow = UIApplication.sharedApplication().delegate!.window!!
        win.backgroundColor = UIColor.whiteColor()
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        // Facebook
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {

        // Facebook
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

