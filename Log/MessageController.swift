//
//  MessageController.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageController {

    static func getMessagesForFriend(friendname: String, completionHandler: @escaping ([String: Any]) -> Void) {
        if let username = CoreDataController.getUserProfile()?.email {
            let request = LOGHTTP.get(url: "/user/messages/\(username)/\(friendname)");

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

    static func sendNewMessage(parameters: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: "/user/messages", parameters: parameters);

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
