//
//  MessageStack.swift
//  Log
//
//  Created by Andrei Villasana on 8/25/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct MessageStack {
    private var messageStack: [Message] = [];
    private var conversationWithFriend: LOGUser?;
    
    mutating func setFriendProfile(friendProfile: LOGUser?) {
        conversationWithFriend = friendProfile;
    }
    
    mutating func setStackOfMessages(stack: [Message]) {
        messageStack = stack;
    }
    
    mutating func appendMessageToMessageStack(messageObj: Message) {
        messageStack.append(messageObj);
    }
    
    func getStackOfMessages() -> [Message] {
        return messageStack;
    }
    
    func getFriendProfile() -> LOGUser? {
        return conversationWithFriend;
    }
}
