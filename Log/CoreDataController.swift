//
//  AppDelegateCoreData.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {

    private init () {} //Private unaccessible initializer

    class func getContext() -> NSManagedObjectContext {
        return (self.persistentContainer.viewContext)
    }

    static var currentUserCoreData: [UserCoreData]? {
        var userResults: [UserCoreData]?
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false

        do {
            userResults = try self.getContext().fetch(fetchRequest)
        } catch {
            // Process Error
        }
        return userResults
    }

    // # Mark - Setters
    class func setUser(userEmail: String, image: NSData) {
        guard let userCoreData: UserCoreData = NSEntityDescription.insertNewObject(forEntityName: "User", into: getContext()) as? UserCoreData else {
            return
        }
        userCoreData.email = userEmail
        userCoreData.image = image
        saveContext()
    }

    // #Mark - Getter
    class func getUserProfile() -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let searchResults = try getContext().fetch(fetchRequest)

            if (searchResults.count > 0) {
                return(searchResults[0])
            } else {
                return nil
            }
        } catch {
            //Process error
        }
        return nil
    }

    // MARK: - Core Data Stack
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "AppState")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
