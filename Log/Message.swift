//
//  Message.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct Message {
    
    private var messageSender: LOGUser?;
    private var message: String?;
    private var dateSent: Date?;
    
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
    
    func getMessageLOGSender() -> LOGUser? {
        return self.messageSender;
    }
    
    func getMessage() -> String? {
        return self.message;
    }
    
    func getDateMessageSent() -> Date? {
        return self.dateSent;
    }
    
}
