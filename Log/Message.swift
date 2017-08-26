//
//  Message.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class Message {
    
    var messageSender: LOGUser?;
    var message: String?;
    var dateSent: Date?;
    
    init(messageSender: LOGUser?, message: String?, dateSent: Date?) {
        guard let _ = messageSender else {
            return;
        }
        guard let _ = message else {
            return;
        }
        guard let _ = dateSent else {
            return;
        }
        
        self.messageSender = messageSender;
        self.message = message;
        self.dateSent = dateSent;
        
    }
    
}
