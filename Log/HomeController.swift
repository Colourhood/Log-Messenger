//
//  HomeController.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class HomeController {
    
    class func getRecentMessages(completion: @escaping (NSArray) -> Void) {
        let username = LOGUserDefaults.username!
        let request = LOGHTTP().get(url: "/user/messages/\(username)");
        
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
