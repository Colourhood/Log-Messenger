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
        // Creation of necessary directories for the app - created under Documents
        LOGFileManager.createDirectoriesInDocuments()
        // Initial Configuration for AWS
        AWSConfig.setAWS()

        let currentUser = UserCoreDataController.getUserProfile()
        if currentUser?.email != nil || currentUser?.firstName != nil || currentUser?.lastName != nil {
            window = FloatingActionWindow()
        } else {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
        CoreDataBP.saveContext()
    }

}
