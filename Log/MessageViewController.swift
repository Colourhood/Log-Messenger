//
//  MessageViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    open var friendConversation: MessageStack?
    var didFriendType: Bool = false
    var didUserType: Bool = false
    var controller = MessageController()
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
        controller.joinChatRoom(friendEmail: friendConversation?.getFriendProfile()?.email)
        registerForKeyboardNotifications()
    }

    deinit {
        deregisterFromKeyboardNotifications()
        controller.leaveChatRoom()
        print("MessageView deinit was called")
    }

    func addGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (MessageViewController.handleGesture))
        self.view.addGestureRecognizer(panGestureRecognizer)
        transitioningDelegate = dismissTransitionDelegate
    }

    @objc func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
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
        friendName.text = friendConversation?.getFriendProfile()?.getName()
    }

    func fetchMessages() {
        // Network request to get all(for now) messages between two users
        guard let friendProfile = friendConversation?.getFriendProfile() else { return }

        controller.getMessagesForFriend(friendEmail: friendProfile.email,
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

                        if sentBy == friendProfile.email {
                            senderUser = friendProfile
                        } else if sentBy == self.controller.userProfile?.email {
                            senderUser = self.controller.userProfile
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
        let friendEmail = friendConversation?.getFriendProfile()?.email
        let parameters = ["sent_by": controller.userProfile?.email,
                          "sent_to": friendEmail,
                          "message": message
                         ] as [String: AnyObject]
        controller.sendNewMessage(parameters: parameters) { (json) in // Server - Database
            print(json)
        }
        controller.messageChat(message: message) // Server - SocketIO
    }

    @IBAction func didPressSendMessageButton() {
        if let message = newMessageTextField.text {
            if !message.isEmpty {
                sendMessage(message: message) // Server - Database
                newMessageTextField.text = "" // Clear text

                let newMessage = Message(sender: controller.userProfile, message: message, date: DateConverter.convert(date: Date(), format: Constants.serverDateFormat))

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
                    controller.emitToChatSocket(event: Constants.stopTyping)
                }
            } else {
                if !didUserType {
                    didUserType = true
                    controller.emitToChatSocket(event: Constants.startTyping)
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
            self.view.frame.size.height = UIScreen.main.bounds.size.height-keyboardSize.size.height
        }
        let debounceTableViewFrame = Debouncer(delay: 0.1) {
            self.messagesTableView.scrollToBottom()
        }
        debounceTableViewFrame.call()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.size.height = UIScreen.main.bounds.size.height
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
        let email = messageProfile?.email

        var cell: MessageTableViewCell?

        func messageCell(identifier: String, withImage: Bool) {
            cell = messagesTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageTableViewCell
            if withImage {
                cell?.userImage.image = messageProfile?.picture
            }
        }

        if let _ = messageData?.getMessage() {
            if email == controller.userProfile?.email {
                if (friendConversation?.getStackOfMessages().count)!-1 == indexPath.row {
                    messageCell(identifier: "UserMessageCell", withImage: true)
                } else {
                    let possibleSameProfile = friendConversation?.getStackOfMessages()[indexPath.row+1]?.getSender()
                    if possibleSameProfile?.email == email {
                        messageCell(identifier: "UserOnlyMessageCell", withImage: false)
                    } else {
                        messageCell(identifier: "UserMessageCell", withImage: true)
                    }
                }
            } else {
                if (friendConversation?.getStackOfMessages().count)!-1 == indexPath.row {
                    messageCell(identifier: "FriendMessageCell", withImage: true)
                } else {
                    let possibleSameProfile = friendConversation?.getStackOfMessages()[indexPath.row+1]?.getSender()
                    if possibleSameProfile?.email == email {
                        messageCell(identifier: "FriendOnlyMessageCell", withImage: false)
                    } else {
                        messageCell(identifier: "FriendMessageCell", withImage: true)
                    }
                }
            }
            cell?.messageLabel.text = messageData?.getMessage()
        } else {
            messageCell(identifier: "FriendTypingMessageCell", withImage: true)
        }

        return cell!
    }

    func insertMessageCell(isTyping: Bool) {
        let dataCount = friendConversation!.getStackOfMessages().count
        let indexPath = IndexPath(row: dataCount-1, section: 0)
        let previousIndexPath = IndexPath(row: dataCount-2, section: 0)

        UIView.setAnimationsEnabled(false)
        messagesTableView.insertRows(at: [indexPath], with: .none)
        messagesTableView.reloadRows(at: [previousIndexPath], with: .none)
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
        if !didFriendType {
            didFriendType = true
            let emptyMessage = Message(sender: (friendConversation?.getFriendProfile())!, message: nil, date: nil)
            friendConversation?.appendMessageToMessageStack(messageObj: emptyMessage)
            insertMessageCell(isTyping: true)
        }
    }

    func friendStoppedTyping() {
        if didFriendType {
            didFriendType = false
            friendConversation?.removeLastMessageFromMessageStack()
            removeTypingMessageCell()
        }
    }

}
