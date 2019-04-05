//
//  AppDelegate.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/9/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FacebookShare
import FBSDKCoreKit
import GoogleMaps
import FBSDKLoginKit
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyB_MWXA_DHGnKZ_O2yHk1pgohaE_jA1ynQ")
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application,
        didFinishLaunchingWithOptions:launchOptions)
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            let options: UNAuthorizationOptions = [.alert, .sound]
            
            center.requestAuthorization(options: options) {
                (granted, error) in
                if !granted {
                    print("Something went wrong")
                }
            }
        } else {
            // Fallback on earlier versions
        }

        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // [END old_delegate]
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     // [START old_options]
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
}
