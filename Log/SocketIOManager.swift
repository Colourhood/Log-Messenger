//
//  File.swift
//  Log
//
//  Created by Andrei Villasana on 10/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import SocketIO

private let socketURL: String = "http://192.168.0.10:7555"
// private let socketURL: String = "http://127.0.0.1:7555"

protocol SocketIODelegate: class {
    func receivedMessage(user: String, message: String, date: String)
    func friendStartedTyping()
    func friendStoppedTyping()
}

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: socketURL)!)
    weak var delegate: SocketIODelegate?

    private override init() {
        super.init()
    }

    func establishConnection() {
        socket.connect()
    }

    func closeConnection() {
        socket.disconnect()
    }

    func subscribe(event: String) {
        socket.on(event) { [weak self] (data, _) in
            guard let `self` = self else { return }
            if data.count > 0 {
                if let data = data[0] as? [String: String] {
                    self.handleEvents(data: data)
                }
            }
        }
    }

    func unsubscribe(event: String) {
        socket.off(event)
    }

    func emit(event: String, data: AnyObject) {
        socket.emit(event, [data])
    }

    private func handleEvents(data: [String: String]) {
        if let delegate = delegate {
            if let eventName = data["event"] {
                switch eventName {
                case Constants.sendMessage:
                    guard let user = data["user_email"],
                          let message = data["message"],
                          let date = data["date"] else { return }
                    delegate.receivedMessage(user: user, message: message, date: date)
                case Constants.startTyping:
                    delegate.friendStartedTyping()
                case Constants.stopTyping:
                    delegate.friendStoppedTyping()
                default:
                    break
                }
            }
        }
    }

}
