//
//  Message.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct Message {

    private var sender: LOGUser;
    private var message: String;
    private var date: String;

    init(sender: LOGUser, message: String, date: String) {
        self.sender = sender;
        self.message = message;
        self.date = date;
    }

    func getSender() -> LOGUser {
        return self.sender;
    }

    func getMessage() -> String {
        return self.message;
    }

    func getDate() -> String {
        return self.date;
    }

}
