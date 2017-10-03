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

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var senderToReceiverLabel: UILabel!;
    @IBOutlet weak var messageLabel: UILabel!;
    @IBOutlet weak var messageView: UIView!;
    @IBOutlet weak var userImage: UIImageView!
}

class MessageViewController: UIViewController {

    @IBOutlet weak var newMessageTextField: UITextField!;
    @IBOutlet weak var messagesTableView: UITableView!;
    @IBOutlet weak var messageNavigator: UINavigationItem!

    var friendConversation: MessageStack?;
    let userData = CoreDataController.getUserProfile();

    override func viewDidLoad() {
        super.viewDidLoad();

        registerForKeyboardNotifications();

        messagesTableView.estimatedRowHeight = 50;
        messagesTableView.rowHeight = UITableViewAutomaticDimension;
        newMessageTextField.autocorrectionType = .no;
        messageNavigator.title = friendConversation?.getFriendProfile()?.getFirstName();
    }

    override func viewWillAppear(_ animated: Bool) {
        //Network request to get all(for now) messages between two users
        let friendProfile = friendConversation?.getFriendProfile();
        let friendname = friendProfile!.getEmail();

        let userProfile = LOGUser.init(handle: nil, email: userData?.email, firstName: nil, lastName: nil, picture: UIImage.init(data: (userData?.image)! as Data));
        let username = userProfile.getEmail();

        MessageController.getMessagesForFriend(friendname: friendname!, completionHandler: { (response) in
            print("Messages between these two friends:\n \(response)");

            //Array of messages for key 'messages'
            if let messages = response["messages"] as? [AnyObject] {

                for messagePacket in messages {
                    if let messageDict = messagePacket as? [String: Any] {
                        let sentBy = messageDict["sentBy"] as? String;
                        let message = messageDict["message"] as? String;
                        var senderUser: LOGUser?;

                        if (sentBy == friendname) {
                            senderUser = friendProfile;
                        } else if (sentBy == username) {
                            senderUser = userProfile;
                        }

                        if let senderUser = senderUser {
                            if let message = message {
                                let messageObj = Message.init(messageSender: senderUser, message: message, dateSent: Date.init());
                                self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj);
                            }
                        }
                        self.messagesTableView.reloadData();
                        self.messagesTableView.scrollToBottom();
                    }
                }
            }
        });
    }

    deinit {
        deregisterFromKeyboardNotifications();
    }

    fileprivate func sendMessage(message: String) {
        if let sentBy = CoreDataController.getUserProfile()?.email,
           let sentTo = friendConversation?.getFriendProfile()?.getEmail() {
            let parameters = ["sentBy": sentBy, "sentTo": sentTo, "message": message];
            MessageController.sendNewMessage(parameters: parameters) { (json) in
                print(json);
            }
        }
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

        let messageProfile = messageData?.getMessageLOGSender();
//        let sender = messageProfile?.getHandle();
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
extension UITableView {
    func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0)
        // This will guarantee rows - 1 >= 0
        if rows > 0 {
            let indexPath = IndexPath(row: rows - 1, section: 0)
                self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
