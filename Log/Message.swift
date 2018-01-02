//
//  Message.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct Message {

    var user: User
    var message: String?
    var date: String?

    init(user: User, message: String?, date: String?) {
        self.user = user
        self.message = message
        self.date = date
    }

}
