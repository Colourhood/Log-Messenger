//
//  SignInController.swift
//  Log
//
//  Created by Andrei Villasana on 9/15/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CoreData

struct SignInController {
        
    static func handleLoginSignUpRequest(url: String, parameters: [String: Any], completion: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: url, parameters: parameters);
        request.responseJSON(completionHandler: { (response) in
            switch (response.result) {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        completion(jsonDict);
                    }
                    break;
                case .failure(let error):
                    print("Error: \(error)");
                    break;
            }
        }).resume();
    }

}
