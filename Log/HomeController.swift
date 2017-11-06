//
//  HomeController.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct HomeController {

    static func getRecentMessages(completion: @escaping ([AnyObject]) -> Void) {
        if let userEmail = CoreDataController.getUserProfile()?.email {
            let request = LOGHTTP.get(url: "/user/messages/\(userEmail)")

            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    if let jsonArray = json as? [AnyObject] {
                        completion(jsonArray)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }).resume()
        }
    }

}
