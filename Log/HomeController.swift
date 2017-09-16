//
//  HomeController.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

class HomeController {
    //User in CoreData
    static var currentUserCoreData: [UserCoreData] {
        var userResults: [UserCoreData]?;
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest();
        do {
            userResults = try CoreDataController.getContext().fetch(fetchRequest);
        } catch {
        }
        return userResults!;
    }
    
    //computed variable
    static var username: String? {
        if let name = UserDefaults.standard.string(forKey: "username") {
            return name;
        }
        return nil;
    }
    
    class func getRecentMessages(completion: @escaping (NSArray) -> Void) {
        let request = LOGHTTP().get(url: "/user/messages/\(username!)");
        
        request.responseJSON(completionHandler: { (response) in
            switch (response.result) {
            case .success(let json):
                let jsonArray = json as! NSArray;
                completion(jsonArray);
                break;
            case .failure(let error):
                print("Error: \(error)");
                break;
            }
        }).resume();
    };
    
}
