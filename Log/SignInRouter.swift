//
//  SignInRouter.swift
//  Log
//
//  Created by Andrei Villasana on 9/15/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class SignInRouter: HTTP {

    func handleLogin(param: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        post(url: "/user/login", parameters: param) { (JSON) in
            completionHandler(JSON)
        }
    }

    func handleSignUp(param: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        post(url: "/user/signup", parameters: param) { (JSON) in
            completionHandler(JSON)
        }
    }

}
