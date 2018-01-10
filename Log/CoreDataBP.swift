//
//  AppDelegateCoreData.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

class CoreDataBP {

    private init () {} // Private unaccessible initializer

    class func getContext() -> NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    // MARK: - Core Data Stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppState")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                //fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    class func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
