//
//  File.swift
//  Log
//
//  Created by Andrei Villasana on 10/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import SocketIO

//private let socketURL: String = "http://192.168.0.10:7555"
private let socketURL: String = "http://127.0.0.1:7555"

class SocketManager: NSObject {
    fileprivate var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: socketURL)!)

    override init() {
        print("Socket Manager was initialized")
        socket.connect()
    }

    deinit {
        print("Socket Manager was deinitialized")
        socket.disconnect()
    }

}

extension SocketManager {

    internal func subscribe(events: [String], completion: @escaping ([String: String]) -> Void) {
        for event in events {
            socket.on(event) { (data, _) in
                if data.count > 0 {
                    guard let result = data[0] as? [String: String] else { return }
                    completion(result)
                }
            }
        }
    }

    internal func unsubscribe(events: [String]) {
        for event in events {
            socket.off(event)
        }
    }

    internal func emit(event: String, data: AnyObject) {
        socket.emit(event, [data])
    }

}
