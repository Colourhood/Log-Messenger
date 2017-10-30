//
//  ViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData
import CryptoSwift

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var senderToReceiverLabel: UILabel!;
    @IBOutlet weak var messageLabel: UILabel!;
    @IBOutlet weak var messageView: UIView!;
    @IBOutlet weak var userImage: UIImageView!
}

class MessageViewController: UIViewController {

    /*UI-IBOutlets*/
    @IBOutlet weak var newMessageTextField: UITextField!;
    @IBOutlet weak var messagesTableView: UITableView!;
    @IBOutlet weak var messageNavigator: UINavigationItem!

    /*UI-IBActions*/
    @IBAction func unwindSegue() {
        dismiss(animated: false, completion: nil);
    }

    /* Class Variables */
    var friendConversation: MessageStack?;
    lazy var userData = CoreDataController.getUserProfile();
    var chatRoomID: String?;

    override func viewDidLoad() {
        super.viewDidLoad();

        //Delegates
        SocketIOManager.sharedInstance.delegate = self;
        prepareUI();

        fetchMessages();
        joinChatRoom();
        registerForKeyboardNotifications();
    }

    func prepareUI() {
        messagesTableView.estimatedRowHeight = 50;
        messagesTableView.rowHeight = UITableViewAutomaticDimension;
        newMessageTextField.autocorrectionType = .no;
        messageNavigator.title = friendConversation?.getFriendProfile()?.getFirstName();
    }

    func updateMessagesTable() {
        DispatchQueue.main.async {
            self.messagesTableView.reloadData();
            self.messagesTableView.scrollToBottom();
        }
    }

    func fetchMessages() {
        //Network request to get all(for now) messages between two users
        let friendProfile = friendConversation?.getFriendProfile();
        let friendname = friendProfile?.getEmail();

        let userProfile = LOGUser.init(email: userData?.email, firstName: nil, lastName: nil, picture: UIImage.init(data: (userData?.image)! as Data));
        let username = userProfile.getEmail();

        MessageController.getMessagesForFriend(friendname: friendname!, completionHandler: { [weak self] (response) in
            guard let `self` = self else { return }
            //print("Messages between these two friends:\n \(response)");

            //Array of messages for key 'messages'
            if let messages = response["messages"] as? [AnyObject] {
                for messagePacket in messages {
                    if let messageDict = messagePacket as? [String: Any] {
                        let sentBy = messageDict["sentBy"] as? String;
                        let message = messageDict["message"] as? String;
                        let date = messageDict["created_at"] as? String;
                        var senderUser: LOGUser?;

                        if (sentBy == friendname) {
                            senderUser = friendProfile;
                        } else if (sentBy == username) {
                            senderUser = userProfile;
                        }

                        if let senderUser = senderUser, let message = message, let date = date {
                                let messageObj = Message.init(sender: senderUser, message: message, date: date);
                                self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj);
                        }
                    }
                }
                self.updateMessagesTable();
            }
        });
    }

    deinit {
        deregisterFromKeyboardNotifications();
        leaveChatRoom();
        print("MessageView deinit was called");
    }

    fileprivate func sendMessage(message: String) {
        let sentTo = friendConversation?.getFriendProfile()?.getEmail();

        let parameters = ["sentBy": userData?.email, "sentTo": sentTo, "message": message] as [String: AnyObject];
        MessageController.sendNewMessage(parameters: parameters) { (json) in //Server - Database
            print(json);
        }
        messageChat(message: message); //Server - SocketIO


    }

}

extension MessageViewController: UITextFieldDelegate {

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil);
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (self.view.frame.origin.y == 0) {
                self.view.frame.origin.y -= keyboardSize.height;
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (self.view.frame.origin.y != 0) {
                self.view.frame.origin.y += keyboardSize.height;
            }
        }
    }

    /* UITextField Delegate Methods*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let message = newMessageTextField.text {
            if (!message.isEmpty) {
                sendMessage(message: message); //Server - Database

                newMessageTextField.text = "";
            }
        }

        return true;
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let param = ["username": userData?.email, "chatID": chatRoomID] as AnyObject;
        SocketIOManager.sharedInstance.emit(event: Constants.startTyping, data: param);
        return true;
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let param = ["username": userData?.email, "chatID": chatRoomID] as AnyObject;
        SocketIOManager.sharedInstance.emit(event: Constants.stopTyping, data: param);
        return true;
    }

}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendConversation = friendConversation {
            return (friendConversation.getStackOfMessages().count);
        }
        return 0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let messageData = friendConversation?.getStackOfMessages()[indexPath.row];
        let messageProfile = messageData?.getSender();

        let email = messageProfile?.getEmail();
        let name = messageProfile?.getFirstName();
        let picture = messageProfile?.getPicture();
        let messageSent = messageData?.getMessage();

        var cell: MessageTableViewCell?;

        if (email == userData?.email) {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: "Message Sender Cell", for: indexPath) as? MessageTableViewCell;
        } else {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: "Message Receiver Cell", for: indexPath) as? MessageTableViewCell;
        }

        cell?.senderToReceiverLabel.text = name;
        cell?.userImage.image = picture;
        cell?.messageLabel.text = messageSent;
        cell?.messageView.layer.cornerRadius = 10;

        return cell!;
    }

}

extension MessageViewController: SocketIODelegate {

    // # Mark - SocketIODelegates
    func receivedMessage(user: String, message: String, date: String) {
        print("Received socket delegate event: Message - \(user): \(message), \(date)");

        let newMessage = Message.init(sender: (friendConversation?.getFriendProfile())!, message: message, date: date);
        friendConversation?.appendMessageToMessageStack(messageObj: newMessage);
        updateMessagesTable();
    }

    func friendStoppedTyping() {
        print("Received socket delegate event: Friend stopped typing");
    }

    func friendStartedTyping() {
        print("Received socket delegate event: Friend started typing");
    }

}

extension UITableView {
    func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0);
        // This will guarantee rows - 1 >= 0
        if rows > 0 {
            let indexPath = IndexPath(row: rows - 1, section: 0);
            self.scrollToRow(at: indexPath, at: .top, animated: false);
        }
    }
}

extension MessageViewController {

    // # Mark - Crypto
    private func generateChatRoomID() {
        if let username = userData?.email, let friendname = friendConversation?.getFriendProfile()?.getEmail() {
            let sortedArray = [username, friendname].sorted().joined(separator: "");
            chatRoomID = sortedArray.sha512();
            print("Chat ID: \(chatRoomID!)");
        }
    }

    // # Mark - SocketIO
    private func subscribeToChatEvents() {
        SocketIOManager.sharedInstance.subscribe(event: Constants.sendMessage);
        SocketIOManager.sharedInstance.subscribe(event: Constants.startTyping);
        SocketIOManager.sharedInstance.subscribe(event: Constants.stopTyping);
    }

    private func unsubscribeFromChatEvents() {
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.sendMessage);
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.startTyping);
        SocketIOManager.sharedInstance.unsubscribe(event: Constants.stopTyping);
    }

    private func joinChatRoom() {
        generateChatRoomID();
        subscribeToChatEvents();

        let param = ["username": userData?.email, "chatID": chatRoomID];
        SocketIOManager.sharedInstance.emit(event: Constants.joinRoom, data: param as AnyObject);
    }

    private func leaveChatRoom() {
        unsubscribeFromChatEvents();

        let param = ["username": userData?.email, "chatID": chatRoomID];
        SocketIOManager.sharedInstance.emit(event: Constants.leaveRoom, data: param as AnyObject);
    }

    private func messageChat(message: String) {
        print("message chat was called, message: \(message)");
        let param = ["username": userData?.email, "chatID": chatRoomID, "message": message, "date": DateConverter.convert(date: Date(), format: Constants.serverDateFormat)] as AnyObject;
        SocketIOManager.sharedInstance.emit(event: Constants.stopTyping, data: param);
        SocketIOManager.sharedInstance.emit(event: Constants.sendMessage, data: param);
    }

}
