//
//  LOGUserDefaults.swift
//  Log
//
//  Created by Andrei Villasana on 9/16/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class LOGUserDefaults {
    
    class func setUser(username: String) {
        let userDefaults = UserDefaults.standard;
        userDefaults.set(username, forKey: "username");
    }
}
