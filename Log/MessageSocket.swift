//
//  MessageSocket.swift
//  Log
//
//  Created by Andrei Villasana on 1/2/18.
//  Copyright © 2018 Andrei Villasana. All rights reserved.
//

import Foundation

private enum ChatEvent: String {
    case join = "join room"
    case leave = "leave room"
    case sendMessage = "send message"
    case startTyping = "start typing"
    case stopTyping = "stop typing"
}

protocol MessageSocketDelegate: class {
    var didFriendType: Bool { get set }
    var didUserType: Bool { get set }

    func receivedMessage(user: String, message: String, date: String)
    func friendStartedTyping(user: String)
    func friendStoppedTyping(user: String)
}

class MessageSocket: SocketManager {
    weak var delegate: MessageSocketDelegate?
    fileprivate let events: [String] = [ChatEvent.sendMessage.rawValue,
                                        ChatEvent.startTyping.rawValue,
                                        ChatEvent.stopTyping.rawValue]

    override init() {
        super.init()
        observeEvents()
    }

    deinit {
        disregardEvents()
    }

}

extension MessageSocket {

    private func observeEvents() {
        subscribe(events: events) { [weak self] (eventData) in
            self?.handle(data: eventData)
        }
    }

    private func disregardEvents() {
        unsubscribe(events: events)
    }

    private func handle(data: [String: String]) {
        guard let delegate = delegate, let event = data["event"], let chatEvent = ChatEvent(rawValue: event) else { return }

        switch chatEvent {
        case .sendMessage:
            guard let user = data["user_email"], let message = data["message"], let date = data["date"] else { return }
            delegate.receivedMessage(user: user, message: message, date: date)
        case .startTyping:
            guard let user = data["user_email"] else { return }
            delegate.friendStartedTyping(user: user)
        case .stopTyping:
            guard let user = data["user_email"] else { return }
            delegate.friendStoppedTyping(user: user)
        default:
            break
        }
    }

}

extension MessageSocket {

    fileprivate func emitChat(event: ChatEvent, param: [String: String]) {
        emit(event: event.rawValue, data: param as AnyObject)
    }

    func join(param: [String: String]) {
        emitChat(event: .join, param: param)
    }

    func leave(param: [String: String]) {
        emitChat(event: .leave, param: param)
    }

    func sendMessage(param: [String: String]) {
        emitChat(event: .sendMessage, param: param)
    }

    func startTyping(param: [String: String]) {
        emitChat(event: .startTyping, param: param)
    }

    func stopTyping(param: [String: String]) {
        emitChat(event: .stopTyping, param: param)
    }
}
