//
//  SocketManager+Protocol.swift
//  Log
//
//  Created by Andrei Villasana on 10/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import SocketIO

protocol SocketManager {
    var socket: SocketIOClient { get set }
    func connect()
    func disconnect()
    func subscribe(events: [String])
    func unsubscribe(events: [String])
    func handler(data: [String: String])
    func emit(event: String, data: AnyObject)
}
