//
//  File.swift
//  Log
//
//  Created by Andrei Villasana on 10/12/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import SocketIO

private let socketURL: String = "http://127.0.0.1:7555";

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager();
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: socketURL)!);

    private override init() {
        super.init();
    }

    func establishConnection() {
        socket.connect();
    }

    func closeConnection() {
        socket.disconnect();
    }

    func subscribe(event: String) {
        socket.on(event) { (data, _) in
            print("Received event \(data[0])");
        }
    }

    func unsubscribe(event: String) {
        socket.off(event);
    }

    func emit(event: String, data: AnyObject) {
        socket.emit(event, [data]);
    }

}
