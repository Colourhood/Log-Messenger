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
    @IBOutlet weak var SenderToReceiverLabel: UILabel!;
    @IBOutlet weak var MessageLabel: UILabel!;
    @IBOutlet weak var MessageView: UIView!;
    @IBOutlet weak var UserImage: UIImageView!
}

class MessageViewController: UIViewController {
    
    @IBOutlet weak var NewMessageTextField: UITextField!;
    @IBOutlet weak var MessagesTableView: UITableView!;
    @IBOutlet weak var MessageNavigator: UINavigationItem!
    
    var friendConversation: MessageStack?;

    override func viewDidLoad() {
        super.viewDidLoad();
        
        registerForKeyboardNotifications();
        
        MessagesTableView.estimatedRowHeight = 50;
        MessagesTableView.rowHeight = UITableViewAutomaticDimension;
        NewMessageTextField.autocorrectionType = .no;
        MessageNavigator.title = friendConversation?.getFriendProfile()?.getFirstName();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currentUser = CoreDataController.getUserProfile();
        //Network request to get all(for now) messages between two users
        let friendProfile = friendConversation?.getFriendProfile();
        let friendname = friendProfile!.getEmail();
        
        let userProfile = LOGUser.init(handle: currentUser?.email, email: currentUser?.email, firstName: currentUser?.email, lastName: currentUser?.email, picture: UIImage.init(data: (currentUser?.image)! as Data));
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

                        let messageObj = Message.init(messageSender: senderUser, message: message, dateSent: Date.init());
                        self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj);
                        self.MessagesTableView.reloadData();
                    }
                }
            }
            
        });
    }
    
    deinit {
        deregisterFromKeyboardNotifications();
    }
    
    fileprivate func sendMessage(message: String) {
        let sentBy = CoreDataController.getUserProfile()?.email;
        let sentTo = friendConversation?.getFriendProfile()?.getEmail();
        
        let parameters = ["sentBy": sentBy, "sentTo": sentTo, "message": message];
        MessageController.sendNewMessage(parameters: parameters) { (json) in
            
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
    
    //A computed property inside the extension that contains a list of messages as example
    var MessageDataSource: MessageStack? {
        let messages = friendConversation;
        return messages;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (MessageDataSource != nil) {
            return (MessageDataSource?.getStackOfMessages().count)!;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageData = MessageDataSource?.getStackOfMessages()[indexPath.row];
        
        let messageProfile = messageData?.getMessageLOGSender();
//        let sender = messageProfile?.getHandle();
        let email = messageProfile?.getEmail();
        let name = messageProfile?.getFirstName();
        let picture = messageProfile?.getPicture();
        let messageSent = messageData?.getMessage();
        
        
        var cell: MessageTableViewCell?;
        
        let useremail = LOGUserDefaults.username!;
            
        if (email == useremail) {
            cell = MessagesTableView.dequeueReusableCell(withIdentifier: "Message Sender Cell", for: indexPath) as? MessageTableViewCell;
        } else {
            cell = MessagesTableView.dequeueReusableCell(withIdentifier: "Message Receiver Cell", for: indexPath) as? MessageTableViewCell;
        }
        
        cell?.SenderToReceiverLabel.text = name;
        cell?.UserImage.image = picture;
        cell?.MessageLabel.text = messageSent;
        cell?.MessageView.layer.cornerRadius = 10;
        
        return cell!;
    }

}

