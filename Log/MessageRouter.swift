//
//  MessageRouter.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class MessageRouter: HTTP {

    func fetchMessages(chatID: String, completionHandler: @escaping ([String: Any]) -> Void) {
        let patchedURL = "/user/messages/t/\(chatID)"
        get(url: patchedURL) { (JSON) in
            completionHandler(JSON)
        }
    }

    func sendMessage(param: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        post(url: "/user/messages", parameters: param) { (JSON) in
            print(JSON)
        }
    }

}
