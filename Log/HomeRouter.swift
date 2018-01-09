//
//  HomeController.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class HomeRouter: HTTP {

    func fetchMessages(userEmail: String, completionHandler: @escaping ([String: Any]) -> Void) {
        let patchedURL = "/user/messages/\(userEmail)"
        get(url: patchedURL) { (JSON) in
            completionHandler(JSON)
        }
    }

}
