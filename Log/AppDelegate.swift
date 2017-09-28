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

        //Creation of necessary directories for the app - created under Documents
        LOGFileManager.createDirectoriesInDocuments();

        //Initial Configuration for AWS
        AWSConfig.setAWS();

        let storyboard = UIStoryboard(name: "Main", bundle: nil);

        let currentUser = CoreDataController.getUserProfile();
        if ((currentUser?.email != nil) || (currentUser?.firstName != nil) || (currentUser?.lastName != nil) || (currentUser?.handle != nil)) {
//      self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MessageViewController");
            self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");

        } else {
            self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController");
        }

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataController.saveContext();
    }

}
