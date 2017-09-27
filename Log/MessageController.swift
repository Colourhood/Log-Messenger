//
//  MessageController.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Alamofire

struct MessageController {
    
    static func getMessagesForFriend(friendname: String, completionHandler: @escaping (NSDictionary) -> Void) {
        let currentUsername = LOGUserDefaults.username!;
        let request = LOGHTTP.get(url: "/user/messages/\(currentUsername)/\(friendname)");
        
        request.responseJSON(completionHandler: { (response) in
            switch(response.result) {
                case .success(let json):
                    let jsonDict = json as! NSDictionary;
                    completionHandler(jsonDict);
                    break;
                case .failure(let error):
                    print("Error: \(error)");
                    break;
            }
        });
    }
        
        request.responseJSON(completionHandler: { (response) in
            switch(response.result) {
                case .success(let json):
                    let jsonDict = json as! NSDictionary;
                    completionHandler(jsonDict);
                    break;
                case .failure(let error):
                    print("Error: \(error)");
                    break;
            }
        });
    }
}
