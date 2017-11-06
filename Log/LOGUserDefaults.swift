//
//  LOGUserDefaults.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct LOGUserDefaults {

    static func setUser(userEmail: String) {
        UserDefaults.standard.set(userEmail, forKey: "user_email")
    }

    // computed variable
    static var userEmail: String? {
        if let email = UserDefaults.standard.string(forKey: "user_email") {
            return email
        }
        return nil
    }
}
