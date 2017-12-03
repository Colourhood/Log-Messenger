//
//  MessageController.swift
//  Log
//
//  Created by Andrei Villasana on 9/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import CryptoSwift

struct MessageController {

    var userProfile: LOGUser?
    var chatRoomID: String?

    init() {
        let userData = UserCoreDataController.getUserProfile()
        userProfile = LOGUser(email: userData?.email,
                              firstName: userData?.firstName,
                              picture: UIImage(data: (userData?.image)! as Data))
    }

    /* HTTP Methods */
    func getMessagesForFriend(friendEmail: String?, completionHandler: @escaping ([String: Any]) -> Void) {
        if let userEmail = UserCoreDataController.getUserProfile()?.email,
           let friendEmail = friendEmail {
            let request = LOGHTTP.get(url: "/user/messages/\(userEmail)/\(friendEmail)")

            request.responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    if let jsonDict = json as? [String: Any] {
                        completionHandler(jsonDict)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }

    func sendNewMessage(parameters: [String: AnyObject], completionHandler: @escaping ([String: Any]) -> Void) {
        let request = LOGHTTP.post(url: "/user/messages", parameters: parameters)

        request.responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                if let jsonDict = json as? [String: Any] {
                    completionHandler(jsonDict)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }

    /* SocketIO Methods */
    mutating func joinChatRoom(friendEmail: String?) {
        func generateChatRoomID() {
            let userEmail = userProfile?.email
            if let userEmail = userEmail, let friendEmail = friendEmail {
                let sortedArray = [userEmail, friendEmail].sorted().joined(separator: "")
                    chatRoomID = sortedArray.sha512()
            }
        }

        func subscribeToChatEvents() {
            SocketIOManager.sharedInstance.subscribe(event: Constants.sendMessage)
            SocketIOManager.sharedInstance.subscribe(event: Constants.startTyping)
            SocketIOManager.sharedInstance.subscribe(event: Constants.stopTyping)
        }

        generateChatRoomID()
        subscribeToChatEvents()
        emitToChatSocket(event: Constants.joinRoom)
    }

    func leaveChatRoom() {
        func unsubscribeFromChatEvents() {
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.sendMessage)
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.startTyping)
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.stopTyping)
        }

        unsubscribeFromChatEvents()
        emitToChatSocket(event: Constants.leaveRoom)
    }

    func messageChat(message: String) {
        let param = ["user_email": userProfile?.email,
                     "chat_id": chatRoomID,
                     "message": message,
                     "date": DateConverter.convert(date: Date(), format: Constants.serverDateFormat)
                    ] as AnyObject
        SocketIOManager.sharedInstance.emit(event: Constants.sendMessage, data: param)
    }

    func emitToChatSocket(event: String) {
        let userEmail = userProfile?.email
        let param = ["user_email": userEmail, "chat_id": chatRoomID] as AnyObject
        SocketIOManager.sharedInstance.emit(event: event, data: param)
    }

}
