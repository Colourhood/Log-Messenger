//
//  MessageStackViewModel.swift
//  Log
//
//  Created by Andrei Villasana on 12/29/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class MessageStackViewModel {

    fileprivate var msObj: MessageStack
    fileprivate var _didFriendType: Bool = false
    fileprivate var _didUserType: Bool = false
    // View Model only displays data to the viewcontroller
    // && View Model handles data between the model

    init (chatID: String) {
        msObj = MessageStack(friends: [:], stack: [], chatID: chatID)
        SocketIOManager.sharedInstance.delegate = self
    }

    var stack: [Message] {
        return msObj.stack
    }

    var chatID: String {
        return msObj.chatID
    }

    func get(friend: String) -> User? {
        guard let friendUser: User = msObj.friends[friend] else { return nil }
        return friendUser
    }

}

extension MessageStackViewModel {

    // Functions that the ViewModel interacts with the model (modifies)
    func set(chatID: String) {
        msObj.chatID = chatID
    }

    func add(message: Message) {
        msObj.stack.append(message)
    }

    func dumpStack() {
        msObj.stack.removeAll()
    }

    func popLastMessage() {
        msObj.stack.removeLast()
    }

}

extension MessageStackViewModel: SocketIODelegate {

    internal var didFriendType: Bool {
        get { return _didFriendType }
        set { _didFriendType = newValue }
    }

    internal var didUserType: Bool {
        get { return _didUserType }
        set { _didUserType = newValue }
    }


    func receivedMessage(user: String, message: String, date: String) {
        if didFriendType {
            didFriendType = false
            popLastMessage()
            removeTypingMessageCell()
        }
        guard let friend = get(friend: user) else { return }
        let message = Message(user: friend, message: message, date: date)
        add(message: message)
        addTableViewCell()
    }

    func friendStartedTyping(user: String) {
        if !didFriendType {
            didFriendType = true
            guard let friend = get(friend: user) else { return }
            let message = Message(user: friend, message: nil, date: nil)
            add(message: message)
            addTableViewCell()
        }
    }

    func friendStoppedTyping(user: String) {
        if didFriendType {
            didFriendType = false
            popLastMessage()
            removeTypingMessageCell()
        }
    }

}
