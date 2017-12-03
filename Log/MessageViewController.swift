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
    var didFriendType: Bool = false
    var didUserType: Bool = false
    lazy var dismissTransitionDelegate = DismissManager()

    /* UI-IBOutlets */
    @IBOutlet weak var newMessageTextField: UITextField!
    @IBOutlet weak fileprivate var messagesTableView: UITableView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.sharedInstance.delegate = self
        prepareUI()
        addGesture()
        fetchMessages()
        joinChatRoom()
        registerForKeyboardNotifications()
    }

    deinit {
        deregisterFromKeyboardNotifications()
        leaveChatRoom()
        print("MessageView deinit was called")
    }

    func addGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (MessageViewController.handleGesture))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            transitioningDelegate = dismissTransitionDelegate
        case .changed:
            if translation.x > 0 {
                view.frame.origin = CGPoint(x: translation.x, y: 0)
            }
        case .ended:
            if translation.x > view.frame.size.width/3*2 || gesture.velocity(in: view).x > 100 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame.origin = CGPoint(x: 0, y: 0)
                })
            }
        case .cancelled:
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 0)
            })
        default:
            break
        }
    }

    func prepareUI() {
        messagesTableView.estimatedRowHeight = 50
        messagesTableView.rowHeight = UITableViewAutomaticDimension
        newMessageTextField.autocorrectionType = .no
        friendName.text = friendConversation?.getFriendProfile()?.getFirstName()
    }

    func fetchMessages() {
        // Network request to get all(for now) messages between two users
        guard let friendProfile = friendConversation?.getFriendProfile() else { return }
        let userProfile = LOGUser(email: userData?.email, firstName: nil, picture: UIImage(data: (userData?.image)! as Data))

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

    @IBAction func didPressSendMessageButton() {
        if let message = newMessageTextField.text {
            if !message.isEmpty {
                sendMessage(message: message) // Server - Database
                newMessageTextField.text = "" // Clear text

                let userProfile = LOGUser(email: userData?.email, firstName: userData?.email, picture: UIImage(data: (userData?.image)! as Data))
                let newMessage = Message(sender: userProfile, message: message, date: DateConverter.convert(date: Date(), format: Constants.serverDateFormat))

                if didFriendType {
                    //Rearrange message typing cell from row and dataSource
                    friendConversation?.removeLastMessageFromMessageStack()
                    removeTypingMessageCell()
                    //Append message to dataSource and to tableview
                    friendConversation?.appendMessageToMessageStack(messageObj: newMessage)
                    insertMessageCell(isTyping: false)
                    let emptyMessage = Message(sender: (friendConversation?.getFriendProfile())!, message: nil, date: nil)
                    friendConversation?.appendMessageToMessageStack(messageObj: emptyMessage)
                    insertMessageCell(isTyping: true)
                } else {
                    friendConversation?.appendMessageToMessageStack(messageObj: newMessage)
                    insertMessageCell(isTyping: false)
                }
                didUserType = false
            }
        }
    }

}

extension MessageViewController: UITextFieldDelegate {

    /* UITextField Delegate Methods */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let message = newMessageTextField.text {

            if message.isEmpty {
                if didUserType {
                    print("It's empty")
                    didUserType = false
                    let param = ["user_email": userData?.email, "chat_id": chatRoomID] as AnyObject
                    SocketIOManager.sharedInstance.emit(event: Constants.stopTyping, data: param)
                }
            } else {
                if !didUserType {
                    didUserType = true
                    let param = ["user_email": userData?.email, "chat_id": chatRoomID] as AnyObject
                    SocketIOManager.sharedInstance.emit(event: Constants.startTyping, data: param)
                }
            }
        }
    }

    // UIKeyboard - Notification Center
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (MessageViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        newMessageTextField.addTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
    }

    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        newMessageTextField.removeTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.size.height -= keyboardSize.size.height
            messagesTableView.bounds.size.height -= keyboardSize.size.height
        }
        self.messagesTableView.scrollToBottom()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size.height = (self.view.window?.frame.size.height)!
    }

}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendConversation = friendConversation {
            return friendConversation.getStackOfMessages().count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageData = friendConversation?.getStackOfMessages()[indexPath.row]
        let messageProfile = messageData?.getSender()
        let email = messageProfile?.getEmail()

        var cell: MessageTableViewCell?

        func messageCell(identifier: String) {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageTableViewCell
            cell?.userImage.image = messageProfile?.getPicture()
        }

        if let _ = messageData?.getMessage() {
            if email == userData?.email {
                messageCell(identifier: "UserMessageCell")
            } else {
                messageCell(identifier: "FriendMessageCell")
                cell?.senderToReceiverLabel.text = messageProfile?.getFirstName()
            }
            cell?.messageLabel.text = messageData?.getMessage()
        } else {
            messageCell(identifier: "FriendTypingMessageCell")
            cell?.senderToReceiverLabel.text = messageProfile?.getFirstName()
        }

        return cell!
    }

    func insertMessageCell(isTyping: Bool) {
        let dataCount = friendConversation!.getStackOfMessages().count
        let indexPath = IndexPath(row: dataCount-1, section: 0)

        UIView.setAnimationsEnabled(false)
        messagesTableView.insertRows(at: [indexPath], with: .none)
        UIView.setAnimationsEnabled(true)

        DispatchQueue.main.async {
            let cell = self.messagesTableView.cellForRow(at: indexPath) as? MessageTableViewCell
            if !isTyping {
                cell?.animatePop()
            } else {
                cell?.animateTyping()
            }
            self.messagesTableView.scrollToBottom()
        }

    }

    func removeTypingMessageCell() {
        let dataCount = friendConversation!.getStackOfMessages().count
        let indexPath = IndexPath(row: dataCount, section: 0)
        let possibleTypingCell = messagesTableView.cellForRow(at: indexPath) as? MessageTableViewCell

        if possibleTypingCell?.reuseIdentifier == "FriendTypingMessageCell" {
            UIView.setAnimationsEnabled(false)
            messagesTableView.deleteRows(at: [indexPath], with: .none)
            UIView.setAnimationsEnabled(true)
        }
    }

}

extension UITableView {

    internal func scrollToBottom() {
        let rows = self.numberOfRows(inSection: 0)
        // This will guarantee rows - 1 >= 0
        if rows > 0 {
            let indexPath = IndexPath(row: rows-1, section: 0)
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
        if didFriendType {
            didFriendType = false
            friendConversation?.removeLastMessageFromMessageStack()
            removeTypingMessageCell()
        }

        let newMessage = Message(sender: (friendConversation?.getFriendProfile())!, message: message, date: date)
        friendConversation?.appendMessageToMessageStack(messageObj: newMessage)
        insertMessageCell(isTyping: false)
    }

    func friendStartedTyping() {
        print("Received socket delegate event: Friend started typing")
        if !didFriendType {
            didFriendType = true
            let emptyMessage = Message(sender: (friendConversation?.getFriendProfile())!, message: nil, date: nil)
            friendConversation?.appendMessageToMessageStack(messageObj: emptyMessage)
            insertMessageCell(isTyping: true)
        }
    }

    func friendStoppedTyping() {
        print("Received socket delegate event: Friend stopped typing")
        if didFriendType {
            didFriendType = false
            friendConversation?.removeLastMessageFromMessageStack()
            removeTypingMessageCell()
        }
    }

    // # Mark - SocketIO - NonDelegate
    private func joinChatRoom() {
        func generateChatRoomID() {
            if let userEmail = userData?.email, let friendEmail = friendConversation?.getFriendProfile()?.getEmail() {
                let sortedArray = [userEmail, friendEmail].sorted().joined(separator: "")
                chatRoomID = sortedArray.sha512()
                print("Chat ID: \(chatRoomID!)")
            }
        }

        func subscribeToChatEvents() {
            SocketIOManager.sharedInstance.subscribe(event: Constants.sendMessage)
            SocketIOManager.sharedInstance.subscribe(event: Constants.startTyping)
            SocketIOManager.sharedInstance.subscribe(event: Constants.stopTyping)
        }

        generateChatRoomID()
        subscribeToChatEvents()
        let param = ["user_email": userData?.email, "chat_id": chatRoomID]
        SocketIOManager.sharedInstance.emit(event: Constants.joinRoom, data: param as AnyObject)
    }

    private func leaveChatRoom() {
        func unsubscribeFromChatEvents() {
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.sendMessage)
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.startTyping)
            SocketIOManager.sharedInstance.unsubscribe(event: Constants.stopTyping)
        }

        unsubscribeFromChatEvents()
        let param = ["user_email": userData?.email, "chat_id": chatRoomID]
        SocketIOManager.sharedInstance.emit(event: Constants.leaveRoom, data: param as AnyObject)
    }

    private func messageChat(message: String) {
        let param = ["user_email": userData?.email, "chat_id": chatRoomID, "message": message, "date": DateConverter.convert(date: Date(), format: Constants.serverDateFormat)] as AnyObject
        SocketIOManager.sharedInstance.emit(event: Constants.sendMessage, data: param)
    }

}
