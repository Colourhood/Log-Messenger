//
//  MessageStackViewModel.swift
//  Log
//
//  Created by Andrei Villasana on 12/29/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let MessageAddCell = Notification.Name("AddMessageTableViewCell")
    static let MessageRemoveCell = Notification.Name("RemoveMessageTableViewCell")
}

class MessageStackViewModel {

    fileprivate var msObj: MessageStack
    fileprivate var socket: MessageSocket = MessageSocket()
    fileprivate var _didFriendType: Bool = false
    fileprivate var _didUserType: Bool = false
    // View Model only displays data to the viewcontroller
    // && View Model handles data between the model

    init (chatID: String) {
        msObj = MessageStack(friends: [:], stack: [], chatID: chatID)
        socket.delegate = self
        socket.join(param: ["user_email": "", "chat_id": chatID])
    }

    deinit {
        socket.delegate = nil
        socket.leave(param: ["user_email": "", "chat_id": chatID])
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

    @discardableResult func popLastMessage() -> Message {
        return msObj.stack.removeLast()
    }

}

extension MessageStackViewModel: MessageSocketDelegate {

    var didFriendType: Bool {
        get { return _didFriendType }
        set { _didFriendType = newValue }
    }

    var didUserType: Bool {
        get { return _didUserType }
        set { _didUserType = newValue }
    }

    func receivedMessage(user: String, message: String, date: String) {
        if didFriendType {
            didFriendType = false
            popLastMessage()
            NotificationCenter.default.post(name: Notification.Name.MessageRemoveCell, object: nil)
        }

        guard let friend = get(friend: user) else { return }
        let message = Message(user: friend, message: message, date: date)
        add(message: message)
        NotificationCenter.default.post(name: Notification.Name.MessageAddCell, object: nil)
    }

    func friendStartedTyping(user: String) {
        if !didFriendType {
            didFriendType = true

            guard let friend = get(friend: user) else { return }
            let message = Message(user: friend, message: nil, date: nil)
            add(message: message)
            NotificationCenter.default.post(name: Notification.Name.MessageAddCell, object: nil)
        }
    }

    func friendStoppedTyping(user: String) {
        if didFriendType {
            didFriendType = false
            popLastMessage()
            NotificationCenter.default.post(name: Notification.Name.MessageRemoveCell, object: nil)
        }
    }

    func userStoppedTyping() {
        socket.startTyping(param: ["user_email": "", "chat_id": chatID])
    }

    func userStartedTyping() {
        socket.stopTyping(param: ["user_email": "", "chat_id": chatID])
    }

    func send(message: String) {
        let param = ["user_email": "",
                     "chat_id": chatID,
                     "message": message,
                     "date": DateConverter.transform(date: Date(), format: .server)
        ]
        socket.sendMessage(param: param)
    }

}
