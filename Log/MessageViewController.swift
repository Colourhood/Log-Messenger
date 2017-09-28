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
        //Network request to get all(for now) messages between two users
        let friendname = friendConversation?.getFriendProfile()?.getEmail();
        MessageController.getMessagesForFriend(friendname: friendname!, completionHandler: { (response) in
            print("Messages between these two friends:\n \(response)");
            
            let messages = response["messages"] as! NSArray; //Array of messages for key 'messages'
            
            for messagePacket in messages {
                let messageDict = messagePacket as! NSDictionary;
                let sentBy = messageDict["sentBy"] as? String;
                let message = messageDict["message"] as? String;
                let senderUser = LOGUser.init(handle: sentBy, email: sentBy, firstName: sentBy, lastName: sentBy, picture: UIImage(named: "defaultUserIcon"));
                
                let messageObj = Message.init(messageSender: senderUser, message: message, dateSent: Date.init());
                
                self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj);
                self.MessagesTableView.reloadData();
                self.MessagesTableView.scrollToBottom()
            }
        });
    }
    
    deinit {
        deregisterFromKeyboardNotifications();
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    } // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    }// if implemented, called in place of textFieldDidEndEditing:
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    } // return NO to not change text
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true;
    } // called when 'return' key pressed. return NO to ignore.
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
extension UITableView {
    func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0)
        let indexPath = IndexPath(row: rows - 1, section: 0)
        self.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

