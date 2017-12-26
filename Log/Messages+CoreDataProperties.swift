//
//  Messages+CoreDataProperties.swift
//  Log
//
//  Created by Andrei Villasana on 12/5/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//
//

import Foundation
import CoreData

extension MessagesCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessagesCoreData> {
        return NSFetchRequest<MessagesCoreData>(entityName: "Messages")
    }

    @NSManaged public var sentBy: String?
    @NSManaged public var message: String?
    @NSManaged public var id: Int64
    @NSManaged public var date: NSDate?

}
