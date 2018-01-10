//
//  AppDelegate.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.white

        // Creation of necessary directories for the app - created under Documents
        LOGFileManager.createDirectoriesInDocuments()

        // Initial Configuration for AWS
        AWSConfig.setAWS()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if UserCoreData.user != nil  {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
        } else {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataBP.saveContext()
    }

}
