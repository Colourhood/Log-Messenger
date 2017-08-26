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
    
    static let andrei = LOGUser.init(handle: "grrrlikestaquitos", email: "andreicrimson@gmail.com", firstName: "Andrei", lastName: "Villasana", picture: UIImage(named: "andreiUserIcon"));
    static let katherine = LOGUser.init(handle: "katherine", email: "stevenpin@gmail.com", firstName: "Katherine", lastName: "Li", picture: UIImage(named: "katherineUserIcon"));
    static let sebastian = LOGUser.init(handle: "theradkiz", email: "sebastianfolzo@gmail.com", firstName: "Sebastian", lastName: "Folzo", picture: UIImage(named: "defaultUserIcon"));
    
    static let date = Date.init();
    
    static var katherineAndreiConversation: MessageStack {
        let conversationStack = MessageStack();
        
        let firstMessage = Message.init(messageSender: andrei, message: "Hi Katherine, how are you doing?", dateSent: MessageDataExample.date);
        let secondMessage = Message.init(messageSender: katherine, message: "I am doing ok, how about you?", dateSent: MessageDataExample.date);
        let thirdMessage = Message.init(messageSender: andrei, message: "Where are you going to be later this evening? And what about on Friday?", dateSent: MessageDataExample.date);
        let fourthMessage = Message.init(messageSender: katherine, message: "How about the movies at ten?", dateSent: MessageDataExample.date);
        
        conversationStack.conversationWithFriend = katherine;
        conversationStack.messageStack.append(firstMessage);
        conversationStack.messageStack.append(secondMessage);
        conversationStack.messageStack.append(thirdMessage);
        conversationStack.messageStack.append(fourthMessage);
        
        return conversationStack;
    }
    
    static var sebastianAndreiConversation: MessageStack {
        let conversationStack = MessageStack();
        
        let firstMessage = Message.init(messageSender: andrei, message: "Hi Sebastian, how are you doing?", dateSent: MessageDataExample.date);
        let secondMessage = Message.init(messageSender: sebastian, message: "I am doing ok, how about you?", dateSent: MessageDataExample.date);
        let thirdMessage = Message.init(messageSender: andrei, message: "Where are you going to be later this evening? And what about on Friday?", dateSent: MessageDataExample.date);
        let fourthMessage = Message.init(messageSender: sebastian, message: "How about the movies at ten?", dateSent: MessageDataExample.date);
        let fithMessage = Message.init(messageSender: sebastian, message: "Actually I think I will be busy", dateSent: date);
        
        conversationStack.conversationWithFriend = sebastian;
        conversationStack.messageStack.append(firstMessage);
        conversationStack.messageStack.append(secondMessage);
        conversationStack.messageStack.append(thirdMessage);
        conversationStack.messageStack.append(fourthMessage);
        conversationStack.messageStack.append(fithMessage);
        
        return conversationStack;
    }
    
    
    class func getConversations() -> [MessageStack] {
        var friendConversationStack: [MessageStack] = [];
        friendConversationStack.append(sebastianAndreiConversation);
        friendConversationStack.append(katherineAndreiConversation);
        return friendConversationStack;
    }
    
    
    
}
