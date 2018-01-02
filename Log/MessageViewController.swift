//
//  MessageViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet weak var newMessageTextField: UITextField!
    @IBOutlet weak var messagesTableView: MessageTableView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    var controller: MessageController!
    var stackViewModel: MessageStackViewModel!

    lazy var dismissTransitionDelegate = DismissManager()

    // Clean up Code for MVVM Architecture
    // Models In App - 1. MessageStack
    // ViewModels - MessageStackViewModel
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGesture()
        controller.joinChatRoom()
        fetchMessages()
        observeKeyboard()
    }

    deinit {
        deregisterFromKeyboardNotifications()
        controller.leaveChatRoom()
        print("MessageView deinit was called")
    }

    func prepareUI() {
        friendName.text = ""
    }

    func fetchMessages() {
        //Clear up any messages that may still be present
        stackViewModel.dumpStack()

        controller.getMessagesForFriend(completionHandler: { [weak self] (response) in
            guard let `self` = self else { return }

            // TODO: Model response using Serializer for the MessageStack & Messages Model

            // Array of messages for key 'messages'
            if let messages = response["messages"] as? [AnyObject] {
                for messagePacket in messages {
                    if let messageDict = messagePacket as? [String: Any] {
                        let sentBy = messageDict["sent_by"] as? String
                        let message = messageDict["message"] as? String
                        let date = messageDict["created_at"] as? String
                        guard let senderUser: User = stackViewModel.get(friend: sentBy) else { return }

                        if sentBy == friendProfile.email {
                            senderUser = friendProfile
                        } else if sentBy == self.controller.userProfile?.email {
                            senderUser = self.controller.userProfile
                        }

                        if let senderUser = senderUser, let message = message, let date = date {
                            let messageObj = Message(user: senderUser, message: message, date: date)
                            self.friendConversation?.appendMessageToMessageStack(messageObj: messageObj)
                        }
                    }
                }
                self.messagesTableView.initialReloadTable()
            }
        })
    }

    fileprivate func sendMessage(message: String) {
        let chatID = stackViewModel.chatID

        let parameters = ["sent_by": controller.userProfile?.email, "message": message, "chat_id": chatID] as [String: AnyObject]

        controller.sendNewMessage(parameters: parameters) { (json) in print(json) }
        controller.messageChat(message: message, chatID: chatID) // Server - SocketIO
    }

    @IBAction func didPressSendMessageButton() {
        if let messageText = newMessageTextField.text {
            if !messageText.isEmpty {
                sendMessage(message: messageText) // Server - Database
                newMessageTextField.text = "" // Clear text

                let message = Message(user: controller.userProfile!, message: messageText, date: DateConverter.convert(date: Date(), format: Constants.serverDateFormat))

                if stackViewModel.didFriendType {
                    //Rearrange message typing cell from row and dataSource
                    stackViewModel.popLastMessage()
                    removeTypingMessageCell()

                    //Append message to dataSource and to tableview
                    stackViewModel.add(message: message)

                    addMessageCell()
                    let emptyMessage = Message(user: stackViewModel.friends[0], message: nil, date: nil)
                    stackViewModel.add(message: emptyMessage)
                    addMessageCell()
                } else {
                    stackViewModel.add(message: message)
                    addMessageCell()
                }
                stackViewModel.didUserType = false
            }
        }
    }


}

extension MessageViewController {

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
}

extension MessageViewController: UITextFieldDelegate {

    /* UITextField Delegate Methods */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let message = newMessageTextField.text {
            if message.isEmpty {
                if stackViewModel.didUserType {
                    stackViewModel.didUserType = false
                    controller.emitToChatSocket(event: Constants.stopTyping)
                }
            } else {
                if !stackViewModel.didUserType {
                    stackViewModel.didUserType = true
                    controller.emitToChatSocket(event: Constants.startTyping)
                }
            }
        }
    }

    // UIKeyboard - Notification Center
    func observeKeyboard() {
        let observableFunctions: [NSNotification.Name : Selector] =
            [NSNotification.Name.UIKeyboardWillHide: #selector (MessageViewController.keyboardDidShow),
             NSNotification.Name.UIKeyboardWillHide: #selector (MessageViewController.textFieldDidChange)]

        for (notification, selector) in observableFunctions {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
        }

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

    private func loadCell(identifier: String, withImage: Bool) ->  UITableViewCell {
        cell = messagesTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageTableViewCell
        if withImage {
            cell?.userImage.image = messageObj.user.picture
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stackViewModel.stack.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageObj = stackViewModel.stack[indexPath.row]

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

    // Inserting && Removing Cells from TableView
    func addMessageCell() {
        let count = stackViewModel.stack.count-1
        let indexPath = IndexPath(row: count, section: 0)
        let previousIndexPath = IndexPath(row: count-1, section: 0)

        UIView.setAnimationsEnabled(false)
        messagesTableView.insertRows(at: [indexPath], with: .none)
        messagesTableView.reloadRows(at: [previousIndexPath], with: .none)
        UIView.setAnimationsEnabled(true)

        messagesTableView.scrollToBottom()
    }

    func removeTypingMessageCell() {
        let count = stackViewModel.stack.count
        let indexPath = IndexPath(row: count, section: 0)
        guard let typingcell = messagesTableView.cellForRow(at: indexPath) else { return }

        if typingcell.reuseIdentifier == MessageCellType.TypingMessageCell.rawValue {
            let previousIndexPath = IndexPath(row: count-1, section: 0)

            UIView.setAnimationsEnabled(false)
            messagesTableView.deleteRows(at: [indexPath], with: .none)
            messagesTableView.reloadRows(at: [previousIndexPath], with: .none)
            UIView.setAnimationsEnabled(true)
        }
    }
}
