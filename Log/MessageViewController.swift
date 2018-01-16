//
//  MessageViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class MessageViewController: DraggableRightViewController {

    @IBOutlet weak var newMessageTextField: UITextField!
    @IBOutlet weak var messagesTableView: MessageTableView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    var stackViewModel: MessageStackViewModel!
    let router = MessageRouter()

    private let observables: [NSNotification.Name: Selector] =
        [Notification.Name.UIKeyboardWillShow: #selector (MessageViewController.keyboardDidShow), // UIKeyboard
         Notification.Name.UIKeyboardWillHide: #selector (MessageViewController.keyboardWillHide), // UIKeyboard
         Notification.Name.MessageAddCell: #selector (MessageViewController.addMessageCell), // UITableView
         Notification.Name.MessageRemoveCell: #selector (MessageViewController.removeTypingMessageCell)] // UITableView

    override func viewDidLoad() {
        super.viewDidLoad()
        renderName()
        fetchMessages()
        observeNotifications()
    }

    deinit {
        disregardNotifications()
        print("MessageViewController deinit was called")
    }

    func renderName() {
        friendName.text = stackViewModel.friends
    }

}

extension MessageViewController {

    //API Calls
    func fetchMessages() {
        // Clear up any messages that may still be present
        stackViewModel.dumpStack()
        // Fetch Messages for given chat id
        router.fetchMessages(chatID: stackViewModel.chatID) { [weak self] (JSON) in
            guard let messageStackArray = JSON["messages"] as? [ [String: Any] ] else { return }

            for messageModel in messageStackArray {
                let sentBy = messageModel["sent_by"] as? String ?? ""
                let message = messageModel["message"] as? String ?? ""
                let date = messageModel["created_at"] as? String ?? ""
                guard let user = self?.stackViewModel.get(friend: sentBy) else { return }

                let messageObj = Message(user: user, message: message, date: date)
                self?.stackViewModel.add(message: messageObj)
            }
            DispatchQueue.main.async {
                self?.messagesTableView.reloadData()
                self?.messagesTableView.scrollToBottom()
            }
        }
    }

}

extension MessageViewController {

    // IBActions
    fileprivate func sendMessage(message: String) {
        stackViewModel.send(message: message)
        router.sendMessage(param: ["sent_by": UserCoreData.user?.email! as Any, "message": message, "chat_id": stackViewModel.chatID]) { (_) in }
    }

    @IBAction func didPressSendMessageButton() {
        guard let messageText = newMessageTextField.text else { return }

        if !messageText.isEmpty {
            sendMessage(message: messageText) // Server - Database
            newMessageTextField.text = "" // Clear text
            stackViewModel.didUserType = false

            guard let user = stackViewModel.get(friend: (UserCoreData.user?.email)!) else { return }
            let message = Message(user: user, message: messageText, date: DateConverter.transform(date: Date(), format: .server))

            if stackViewModel.didFriendType {
                // Store last message reference && Rearrange message typing cell from row and dataSource
                let typingMessage = stackViewModel.popLastMessage()
                removeTypingMessageCell()

                //Append message to dataSource and to tableview
                stackViewModel.add(message: message)
                addMessageCell()
                stackViewModel.add(message: typingMessage)
                addMessageCell() 
            } else {
                stackViewModel.add(message: message)
                addMessageCell()
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
        guard let message = newMessageTextField.text else { return }

        if message.isEmpty {
            if stackViewModel.didUserType {
                stackViewModel.didUserType = false
                stackViewModel.userStoppedTyping()
            }
        } else {
            if !stackViewModel.didUserType {
                stackViewModel.didUserType = true
                stackViewModel.userStartedTyping()
            }
        }

    }

    // UIKeyboard - Notification Center
    func observeNotifications() {
        for (notification, selector) in observables {
            NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
        }
        newMessageTextField.addTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
    }

    func disregardNotifications() {
        for (notification, _) in observables {
            NotificationCenter.default.removeObserver(self, name: notification, object: nil)
        }
        newMessageTextField.removeTarget(self, action: #selector (MessageViewController.textFieldDidChange), for: .editingChanged)
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
            let userCells = [MessageCellType.userMessageCell, MessageCellType.userPreviousMessageCell]
            let friendCells = [MessageCellType.friendMessageCell, MessageCellType.friendPreviousMessageCell]
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
            if cellType == .typingMessageCell {
                guard let typingCell = messagesTableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as? MessageTypingTableViewCell else { return UITableViewCell() }
                typingCell.userImage.image = userObj.picture
                return typingCell
            } else {
                guard let messageCell = messagesTableView.dequeueReusableCell(withIdentifier: cellType.rawValue, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
                if cellType == .friendMessageCell || cellType == .userMessageCell {
                    messageCell.userImage.image = userObj.picture
                }
                messageCell.messageLabel.text = message
                return messageCell
            }
        }

        if message != nil {
            if email == UserCoreData.user?.email! {
                // Load cell that is classified as user cells
                return loadCell(cellType: determineCellType(isUser: true))
            } else {
                // Load cell that is classified as friend cells
                return loadCell(cellType: determineCellType(isUser: false))
            }
        } else {
            // Load cell that is classified as typing cell
            return loadCell(cellType: .typingMessageCell)
        }
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

        guard let cell = messagesTableView.cellForRow(at: indexPath) else { return }

        if cell.reuseIdentifier == MessageCellType.typingMessageCell.rawValue {
            guard let typingCell = cell as? MessageTypingTableViewCell else { return }
            typingCell.animateTyping()
        } else {
            guard let messageCell = cell as? MessageTableViewCell else { return }
            messageCell.animatePop()
        }
    }

    @objc func removeTypingMessageCell() {
        let count = stackViewModel.stack.count
        let indexPath = IndexPath(row: count, section: 0)
        guard let typingcell = messagesTableView.cellForRow(at: indexPath) else { return }

        if typingcell.reuseIdentifier == MessageCellType.typingMessageCell.rawValue {
            let previousIndexPath = IndexPath(row: count-1, section: 0)

            UIView.setAnimationsEnabled(false)
            messagesTableView.deleteRows(at: [indexPath], with: .none)
            messagesTableView.reloadRows(at: [previousIndexPath], with: .none)
            UIView.setAnimationsEnabled(true)
            messagesTableView.scrollToBottom()
        }
    }
}
