//
//  LOGUserDefaults.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct LOGUserDefaults {

    static func setUser(username: String) {
        UserDefaults.standard.set(username, forKey: "username");
    }

    //computed variable
    static var username: String? {
        if let name = UserDefaults.standard.string(forKey: "username") {
            return name;
        }
        return nil;
    }
}
