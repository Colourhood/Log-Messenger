//
//  UserCoreData.swift
//  Log
//
//  Created by Andrei Villasana on 11/6/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

class UserCoreDataController {

    static var currentUserCoreData: [UserCoreData]? {
        var userResults: [UserCoreData]?
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false

        do {
            userResults = try CoreDataBP.getContext().fetch(fetchRequest)
        } catch {
            // Process Error
        }
        return userResults
    }

    // # Mark - Setters
    class func setUser(userEmail: String, image: NSData) {
        print("Image data: \(image)")
        guard let userCoreData: UserCoreData = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataBP.getContext()) as? UserCoreData else { return }
        userCoreData.email = userEmail
        userCoreData.image = image
        CoreDataBP.saveContext()
    }

    // #Mark - Getter
    class func getUserProfile() -> UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let searchResults = try CoreDataBP.getContext().fetch(fetchRequest)

            if searchResults.count > 0 {
                return searchResults[0]
            } else {
                return nil
            }
        } catch {
            // Process error
        }
        return nil
    }

}
