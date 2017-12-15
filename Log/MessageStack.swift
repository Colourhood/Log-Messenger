//
//  MessageStack.swift
//  Log
//
//  Created by Andrei Villasana on 8/25/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageStack {
    private var messageStack: [Message?] = []
    private var chatID: String?
    private var friends: LOGUser?

    mutating func setFriends(friendProfile: LOGUser?) {
        friends = friendProfile
    }

    mutating func setStackOfMessages(stack: [Message]) {
        messageStack = stack
    }

    mutating func setChatID(chatIdentifier: String) {
        chatID = chatIdentifier
    }

    mutating func appendMessageToMessageStack(messageObj: Message?) {
        messageStack.append(messageObj)
    }

    mutating func removeLastMessageFromMessageStack() {
        messageStack.removeLast()
    }

    func getStackOfMessages() -> [Message?] {
        return messageStack
    }

    func getFriendProfile() -> LOGUser? {
        return friends
    }

    func getChatID() -> String? {
        return chatID
    }

}
