//
//  ViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData
import CryptoSwift

class MessageViewController: UIViewController {
    /* Class Variables */
    open var friendConversation: MessageStack?
    var userData = UserCoreDataController.getUserProfile()
    var chatRoomID: String?

    /* UI-IBOutlets */
    @IBOutlet weak var newMessageTextField: UITextField!
    @IBOutlet weak fileprivate var messagesTableView: UITableView!
    @IBOutlet weak var messageNavigator: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.sharedInstance.delegate = self
        prepareUI()
        fetchMessages()
        joinChatRoom()
        registerForKeyboardNotifications()
    }

    deinit {
        deregisterFromKeyboardNotifications()
        leaveChatRoom()
        print("MessageView deinit was called")
    }

    func prepareUI() {
        messagesTableView.estimatedRowHeight = 50
        messagesTableView.rowHeight = UITableViewAutomaticDimension
        newMessageTextField.autocorrectionType = .no
        messageNavigator.title = friendConversation?.getFriendProfile()?.getFirstName()
    }

    func fetchMessages() {
        // Network request to get all(for now) messages between two users
        guard let friendProfile = friendConversation?.getFriendProfile() else { return }
        let userProfile = LOGUser(email: userData?.email, firstName: nil, lastName: nil, picture: UIImage(data: (userData?.image)! as Data))

        MessageController.getMessagesForFriend(friendEmail: friendProfile.getEmail()!,
                                               completionHandler: { [weak self] (response) in
            guard let `self` = self else { return }

            // Array of messages for key 'messages'
            if let messages = response["messages"] as? [AnyObject] {
                for messagePacket in messages {
                    if let messageDict = messagePacket as? [String: Any] {
                        let sentBy = messageDict["sent_by"] as? String
                        let message = messageDict["message"] as? String
                        let date = messageDict["created_at"] as? String
                        var senderUser: LOGUser?

                        if sentBy == friendProfile.getEmail() {
                            senderUser = friendProfile
                        } else if sentBy == userProfile.getEmail() {
                            senderUser = userProfile
                        }

                        if let senderUser = senderUser, let message = message, let date = date {
                                let messageObj = Message(sender: senderUser, message: message, date: date)
                                self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj)
                        }
                    }
                }
                self.messagesTableView.initialReloadTable()
            }
        })
    }

    fileprivate func sendMessage(message: String) {
        let friendEmail = friendConversation?.getFriendProfile()?.getEmail()
        let parameters = ["sent_by": userData?.email, "sent_to": friendEmail, "message": message] as [String: AnyObject]
        MessageController.sendNewMessage(parameters: parameters) { (json) in // Server - Database
            print(json)
        }
        messageChat(message: message) // Server - SocketIO
    }

}

extension MessageViewController: UITextFieldDelegate {

    /* UITextField Delegate Methods */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let message = newMessageTextField.text {
            if !message.isEmpty {
                sendMessage(message: message) // Server - Database
                newMessageTextField.text = "" // Clear text

                let userProfile = LOGUser(email: userData?.email, firstName: userData?.email, lastName: userData?.email, picture: UIImage(data: (userData?.image)! as Data))
                let newMessage = Message(sender: userProfile, message: message, date: DateConverter.convert(date: Date(), format: Constants.serverDateFormat))

                friendConversation?.appendMessageToMessageStack(messageObj: newMessage)
                popMessage()
            }
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let param = ["user_email": userData?.email, "chat_id": chatRoomID] as AnyObject
        SocketIOManager.sharedInstance.emit(event: Constants.startTyping, data: param)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let param = ["user_email": userData?.email, "chat_id": chatRoomID] as AnyObject
        SocketIOManager.sharedInstance.emit(event: Constants.stopTyping, data: param)
        return true
    }

    // UIKeyboard - Notification Center

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue) {
            self.view.frame.origin.y = 0
        }
    }

}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendConversation = friendConversation {
            return (friendConversation.getStackOfMessages().count)
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageData = friendConversation?.getStackOfMessages()[indexPath.row]
        let messageProfile = messageData?.getSender()
        let email = messageProfile?.getEmail()

        var cell: MessageTableViewCell?

        func messageCellUI() {
            cell?.userImage.image = messageProfile?.getPicture()
            cell?.messageLabel.text = messageData?.getMessage()
        }

        if email == userData?.email {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as? MessageTableViewCell
            messageCellUI()
        } else {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: "FriendMessageCell", for: indexPath) as? MessageTableViewCell
            cell?.senderToReceiverLabel.text = messageProfile?.getFirstName()
            messageCellUI()
        }

        return cell!
    }

    func popMessage() {
        DispatchQueue.main.async {
            let dataCount = self.friendConversation!.getStackOfMessages().count
            let indexPath = IndexPath(row: dataCount-1, section: 0)

            UIView.setAnimationsEnabled(false)
            self.messagesTableView.insertRows(at: [indexPath], with: .none)
            UIView.setAnimationsEnabled(true)
            self.messagesTableView.scrollToBottom()

            let cell = self.messagesTableView.cellForRow(at: indexPath) as? MessageTableViewCell
            cell?.animate()
        }
    }

}

extension UITableView {

    internal func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0)
        // This will guarantee rows - 1 >= 0
        if rows > 0 {
            let indexPath = IndexPath(row: rows - 1, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    func initialReloadTable() {
        DispatchQueue.main.async {
            self.reloadData()
            self.scrollToBottom()
        }
    }

}

extension MessageViewController: SocketIODelegate {

    // # Mark - SocketIODelegates
    func receivedMessage(user: String, message: String, date: String) {
        print("Received socket delegate event: Message - \(user): \(message), \(date)")
        let newMessage = Message(sender: (friendConversation?.getFriendProfile())!, message: message, date: date)
        friendConversation?.appendMessageToMessageStack(messageObj: newMessage)
        popMessage()
    }

    func friendStoppedTyping() {
        print("Received socket delegate event: Friend stopped typing")
    }

    func friendStartedTyping() {
        print("Received socket delegate event: Friend started typing")
    }

    // # Mark - SocketIO - NonDelegate
    private func subscribeToChatEvents() {
        SocketIOManager.sharedInstance.subscribe(event: Constants.sendMessage)
        SocketIOManager.sharedInstance.subscribe(event: Constants.startTyping)
        SocketIOManager.sharedInstance.subscribe(event: Constants.stopTyping)
    }

    private func unsubscribeFromChatEvents() {
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.sendMessage)
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.startTyping)
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.stopTyping)
    }

    // # Mark - Crypto
    private func generateChatRoomID() {
        if let userEmail = userData?.email, let friendEmail = friendConversation?.getFriendProfile()?.getEmail() {
            let sortedArray = [userEmail, friendEmail].sorted().joined(separator: "")
            chatRoomID = sortedArray.sha512()
            print("Chat ID: \(chatRoomID!)")
        }
    }

    private func joinChatRoom() {
        generateChatRoomID()
        subscribeToChatEvents()
        let param = ["user_email": userData?.email, "chat_id": chatRoomID]
        SocketIOManager.sharedInstance.emit(event: Constants.joinRoom, data: param as AnyObject)
    }

    private func leaveChatRoom() {
        unsubscribeFromChatEvents()
        let param = ["user_email": userData?.email, "chat_id": chatRoomID]
        SocketIOManager.sharedInstance.emit(event: Constants.leaveRoom, data: param as AnyObject)
    }

    private func messageChat(message: String) {
        print("message chat was called, message: \(message)")
        let param = ["user_email": userData?.email, "chat_id": chatRoomID, "message": message, "date": DateConverter.convert(date: Date(), format: Constants.serverDateFormat)] as AnyObject
        SocketIOManager.sharedInstance.emit(event: Constants.stopTyping, data: param)
        SocketIOManager.sharedInstance.emit(event: Constants.sendMessage, data: param)
    }

}
