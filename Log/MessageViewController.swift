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
    private lazy var dismissTransitionDelegate = DismissManager()
    private let observables: [NSNotification.Name : Selector] = [Notification.Name.UIKeyboardWillShow: #selector (MessageViewController.keyboardDidShow), // UIKeyboard
                                                                 Notification.Name.UIKeyboardWillHide: #selector (MessageViewController.keyboardWillHide), // UIKeyboard
                                                                 Notification.Name.MessageAddCell: #selector (MessageViewController.addMessageCell), // UITableView
                                                                 Notification.Name.MessageRemoveCell: #selector (MessageViewController.removeTypingMessageCell)] // UITableView

    // Clean up Code for MVVM Architecture
    // Models In App - 1. MessageStack
    // ViewModels - MessageStackViewModel
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGesture()
        fetchMessages()
        observeNotifications()
    }

    deinit {
        disregardNotifications()
        print("MessageViewController deinit was called")
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
                        guard let sentBy = messageDict["sent_by"] as? String else { return }
                        let message = messageDict["message"] as? String
                        let date = messageDict["created_at"] as? String
                        guard let senderUser: User = self.stackViewModel.get(friend: sentBy) else { return }

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
        guard let messageText = newMessageTextField.text else { return }
        
        if !messageText.isEmpty {
            sendMessage(message: messageText) // Server - Database
            newMessageTextField.text = "" // Clear text
            stackViewModel.didUserType = false

            let message = Message(user: controller.userProfile!, message: messageText, date: DateConverter.convert(date: Date(), format: Constants.serverDateFormat))

            if stackViewModel.didFriendType {
                // Store last message reference && Rearrange message typing cell from row and dataSource
                let typingMessage = stackViewModel.popLastMessage()
                removeTypingMessageCell()

                //Append message to dataSource and to tableview
                stackViewModel.add(message: message)
                stackViewModel.add(message: typingMessage)
                addMessageCell() // Would I get the same results? TOTEST

//                stackViewModel.add(message: message)
//                addMessageCell()
//
//                stackViewModel.add(message: typingMessage)
//                addMessageCell()
            } else {
                stackViewModel.add(message: message)
                addMessageCell()
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
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.view.frame.origin = CGPoint(x: 0, y: 0)
                })
            }
        case .cancelled:
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.view.frame.origin = CGPoint(x: 0, y: 0)
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
        guard let message = newMessageTextField.text else { return }

        if message.isEmpty {
            if stackViewModel.didUserType {
                stackViewModel.didUserType = false
                stackViewModel.us
            }
        } else {
            if !stackViewModel.didUserType {
                stackViewModel.didUserType = true
                stackViewModel.socket.emitChat(event: ChatEvent.start, param: param)
            }
        }

    }

    // UIKeyboard - Notification Center
    func observeNotifications() {
        for (notification, selector) in observables {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
        }
        //newMessageTextField.addTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
    }

    func disregardNotifications() {
        for (notification, _) in observables {
            NotificationCenter.default.removeObserver(self, name: notification, object: nil)
        }
        //newMessageTextField.removeTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let debounceTableViewFrame = Debouncer(delay: 0.1) { [weak self] in self?.messagesTableView.scrollToBottom() }

        view.frame.size.height = UIScreen.main.bounds.size.height-keyboardSize.size.height
        debounceTableViewFrame.call()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.size.height = UIScreen.main.bounds.size.height
    }

}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stackViewModel.stack.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIndex = indexPath.row
        let messageObj = stackViewModel.stack[cellIndex]
        let userObj = messageObj.user
        let message = messageObj.message
        let email = userObj.email

        func determineCellType(isUser: Bool) -> MessageCellType {
            let userCells = [MessageCellType.UserMessageCell, MessageCellType.UserPreviousMessageCell]
            let friendCells = [MessageCellType.FriendMessageCell, MessageCellType.FriendPreviousMessageCell]
            var cellArrayType: [MessageCellType]

            isUser ? (cellArrayType = userCells) : (cellArrayType = friendCells)

            if stackViewModel.stack.count-1 == cellIndex {
                return cellArrayType[0]
            } else {
                let previousUser = stackViewModel.stack[cellIndex+1].user
                return previousUser.email == email ? cellArrayType[1] : cellArrayType[0]
            }
        }

        func loadCell(cellType: MessageCellType) -> UITableViewCell {
            if cellType == MessageCellType.TypingMessageCell {
                guard let typingCell = messagesTableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as? MessageTypingTableViewCell else { }
                typingCell.userImage.image = userObj.picture
                return typingCell
            } else {
                guard let messageCell = messagesTableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as? MessageTableViewCell else { }
                messageCell.userImage.image = userObj.picture
                messageCell.messageLabel.text = message
                return messageCell
            }
        }

        if let _ = message {
            if email == controller.userProfile?.email {
                // Load cell that is classified as user cells
                return loadCell(cellType: determineCellType(isUser: true))
            } else {
                // Load cell that is classified as friend cells
                return loadCell(cellType: determineCellType(isUser: false))
            }
            //cell?.messageLabel.text = messageData?.getMessage()
        } else {
            // Load cell that is classified as typing cell
            return loadCell(cellType: MessageCellType.TypingMessageCell)
        }

        return UITableViewCell()
    }

    // Inserting && Removing Cells from TableView
    @objc func addMessageCell() {
        let count = stackViewModel.stack.count-1
        let indexPath = IndexPath(row: count, section: 0)
        let previousIndexPath = IndexPath(row: count-1, section: 0)

        UIView.setAnimationsEnabled(false)
        messagesTableView.insertRows(at: [indexPath], with: .none)
        messagesTableView.reloadRows(at: [previousIndexPath], with: .none)
        UIView.setAnimationsEnabled(true)

        messagesTableView.scrollToBottom()
    }

    @objc func removeTypingMessageCell() {
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
