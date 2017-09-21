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
        
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest();
        
        do {
            let searchResults = try CoreDataController.getContext().fetch(fetchRequest);
            
            if (searchResults.count > 0) {
                for result in searchResults as [UserCoreData] {
                    if ((result.email != nil) || (result.firstName != nil) || (result.lastName != nil) || (result.handle != nil)) {
//                        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MessageViewController");
                        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");

                    } else {
                        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController");
                    }
                }
            } else {
                self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController");
            }
        } catch {
            //PROCESS ERROR
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
        CoreDataController.saveContext();
    }


}

