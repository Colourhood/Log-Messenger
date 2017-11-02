//
//  MessageDataExample.swift
//  Log
//
//  Created by Andrei Villasana on 8/21/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import UIKit

class MessageDataExample {

    static let andrei = LOGUser.init(email: "andreicrimson@gmail.com", firstName: "Andrei", lastName: "Villasana", picture: UIImage(named: "andreiUserIcon"))
    static let katherine = LOGUser.init(email: "katherineli@gmail.com", firstName: "Katherine", lastName: "Li", picture: UIImage(named: "katherineUserIcon"))
    static let sebastian = LOGUser.init(email: "sebastianfolzo@gmail.com", firstName: "Sebastian", lastName: "Folzo", picture: UIImage(named: "defaultUserIcon"))

    static let date = "8:00 pm"

    static var katherineAndreiConversation: MessageStack {
        var conversationStack = MessageStack()

        let firstMessage = Message.init(sender: andrei, message: "Hi Katherine, how are you doing?", date: MessageDataExample.date)
        let secondMessage = Message.init(sender: katherine, message: "I am doing ok, how about you?", date: MessageDataExample.date)
        let thirdMessage = Message.init(sender: andrei, message: "Where are you going to be later this evening? And what about on Friday?", date: MessageDataExample.date)
        let fourthMessage = Message.init(sender: katherine, message: "How about the movies at ten?", date: MessageDataExample.date)

        conversationStack.setFriendProfile(friendProfile: katherine)
        conversationStack.appendMessageToMessageStack(messageObj: firstMessage)
        conversationStack.appendMessageToMessageStack(messageObj: secondMessage)
        conversationStack.appendMessageToMessageStack(messageObj: thirdMessage)
        conversationStack.appendMessageToMessageStack(messageObj: fourthMessage)

        return conversationStack
    }

    static var sebastianAndreiConversation: MessageStack {
        var conversationStack = MessageStack()

        let firstMessage = Message.init(sender: andrei, message: "Hi Sebastian, how are you doing?", date: MessageDataExample.date)
        let secondMessage = Message.init(sender: sebastian, message: "I am doing ok, how about you?", date: MessageDataExample.date)
        let thirdMessage = Message.init(sender: andrei, message: "Where are you going to be later this evening? And what about on Friday?", date: MessageDataExample.date)
        let fourthMessage = Message.init(sender: sebastian, message: "How about the movies at ten?", date: MessageDataExample.date)
        let fithMessage = Message.init(sender: sebastian, message: "Actually I think I will be busy", date: date)

        conversationStack.setFriendProfile(friendProfile: sebastian)
        conversationStack.appendMessageToMessageStack(messageObj: firstMessage)
        conversationStack.appendMessageToMessageStack(messageObj: secondMessage)
        conversationStack.appendMessageToMessageStack(messageObj: thirdMessage)
        conversationStack.appendMessageToMessageStack(messageObj: fourthMessage)
        conversationStack.appendMessageToMessageStack(messageObj: fithMessage)

        return conversationStack
    }

    class func getConversations() -> [MessageStack] {
        var friendConversationStack: [MessageStack] = []
        friendConversationStack.append(sebastianAndreiConversation)
        friendConversationStack.append(katherineAndreiConversation)
        return friendConversationStack
    }

}
