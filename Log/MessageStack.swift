//
//  MessageStack.swift
//  Log
//
//  Created by Andrei Villasana on 8/25/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageStack {
    var friends: [String: User]
    var stack: [Message]
    var chatID: String
}
