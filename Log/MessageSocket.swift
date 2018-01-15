//
//  MessageSocket.swift
//  Log
//
//  Created by Andrei Villasana on 1/2/18.
//  Copyright © 2018 Andrei Villasana. All rights reserved.
//

import Foundation
import SocketIO

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

    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: AppURL.socketURL)!)
    weak var delegate: MessageSocketDelegate?
    fileprivate let events: [String] = [ChatEvent.sendMessage.rawValue,
                                        ChatEvent.startTyping.rawValue,
                                        ChatEvent.stopTyping.rawValue]

    init() {
        connect()
        subscribe(events: events)
    }

    deinit {
        unsubscribe(events: events)
        disconnect()
    }

    func connect() {
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func subscribe(events: [String]) {
        for event in events {
            socket.on(event) { [weak self] (data, _) in
                if data.count > 0 {
                    guard let result = data[0] as? [String: String] else { return }
                    self?.handler(data: result)
                }
            }
        }
    }

    func unsubscribe(events: [String]) {
        for event in events {
            socket.off(event)
        }
    }

    func handler(data: [String: String]) {
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

    func emit(event: String, data: AnyObject) {
        socket.emit(event, with: [data])
    }

}

extension MessageSocket {

    fileprivate func emitChat(event: ChatEvent, param: [String: String]) {
        emit(event: event.rawValue, data: param as AnyObject)
    }

    func join(param: [String: String]) {
        let state = socket.status
        switch state {
        case .connected:
            print("Socket was connected, time to join chat")
            emitChat(event: .join, param: param)
        case .connecting:
            print("Socket is in process of connecting")
            let debouncer = Debouncer(delay: 2.0, callback: { [weak self] in self?.join(param: param) })
            debouncer.call()
        default:
            break
        }

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
