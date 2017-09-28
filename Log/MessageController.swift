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
    
    static func getMessagesForFriend(friendname: String, completionHandler: @escaping ([String: Any]) -> Void) {
        let currentUsername = LOGUserDefaults.username!;
        let request = LOGHTTP.get(url: "/user/messages/\(currentUsername)/\(friendname)");
        
        request.responseJSON(completionHandler: { (response) in
            switch(response.result) {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        completionHandler(jsonDict);
                    }
                    break;
                case .failure(let error):
                    print("Error: \(error)");
                    break;
            }
        });
    }
    
    static func sendNewMessage(parameters: Parameters, completionHandler: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: "/url/messages", parameters: parameters);
        
        request.responseJSON(completionHandler: { (response) in
            switch(response.result) {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        completionHandler(jsonDict);
                    }
                    break;
                case .failure(let error):
                    print("Error: \(error)");
                    break;
            }
        });
    }
}
