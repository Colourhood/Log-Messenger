//
//  User+CoreDataClass.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

@objc(UserCoreData)
public class UserCoreData: NSManagedObject {

    class var user: UserCoreData? {
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false

        guard let results = try? CoreDataBP.getContext().fetch(fetchRequest).first else { return nil }
        return results
    }

    // # Mark - Setters
    class func set(email: String, name: String, image: NSData) {
        guard let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataBP.getContext()) as? UserCoreData else { return }
        user.email = email
        user.firstName = name
        user.image = image
        CoreDataBP.saveContext()
    }

}
