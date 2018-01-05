//
//  MessageController.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageController {

    init() {
    }

    /* HTTP Methods */
    func getMessagesForFriend(completionHandler: @escaping ([String: Any]) -> Void) {
        guard let userEmail = userProfile?.email, let chatID = chatID else { return }
        let request = LOGHTTP.get(url: "/user/messages/\(userEmail)/\(chatID)")

        request.responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                if let jsonDict = json as? [String: Any] {
                    completionHandler(jsonDict)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }

    func sendNewMessage(parameters: [String: AnyObject], completionHandler: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: "/user/messages", parameters: parameters)

        request.responseJSON(completionHandler: { (response) in
            switch response.result {
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
