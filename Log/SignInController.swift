//
//  SignInController.swift
//  Log
//
//  Created by Andrei Villasana on 9/15/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

class SignInController {
        
    class func handleLoginSignUpRequest(url: String, email: String?, password: String?, completion: @escaping (NSDictionary) -> Void) {
        
        let request = LOGHTTP().post(url: url, parameters: ["username": email!, "password": password!]);
        request.responseJSON(completionHandler: { (response) in
            switch (response.result) {
            case .success(let json):
                let jsonDict = json as! NSDictionary;
                if let statusCode = response.response?.statusCode {
                    if (statusCode == 200) {
                        completion(jsonDict);
                    }
                } else {
                    print("Status code error: \(json)");
                }
                break;
            case .failure(let error):
                print("Error: \(error)");
                break;
            }
        }).resume();
    }

}
