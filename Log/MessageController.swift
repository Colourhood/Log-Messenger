//
//  MessageController.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageController {

    static func getMessagesForFriend(friendEmail: String, completionHandler: @escaping ([String: Any]) -> Void) {
        if let userEmail = CoreDataController.getUserProfile()?.email {
            let request = LOGHTTP.get(url: "/user/messages/\(userEmail)/\(friendEmail)")

            request.responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        completionHandler(jsonDict)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }

    static func sendNewMessage(parameters: [String: AnyObject], completionHandler: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: "/user/messages", parameters: parameters)

        request.responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case .success(let json):
                if let jsonDict = json as? [String: Any] {
                    completionHandler(jsonDict)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }

}
