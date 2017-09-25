//
//  User+CoreDataProperties.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

extension UserCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
        return NSFetchRequest<UserCoreData>(entityName: "User");
    }

    @NSManaged public var email: String?;
    @NSManaged public var firstName: String?;
    @NSManaged public var handle: String?;
    @NSManaged public var lastName: String?;
    @NSManaged public var image: Data?;

}
