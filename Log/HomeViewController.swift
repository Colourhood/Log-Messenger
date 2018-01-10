//
//  HomeViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var friendSearchBar: UISearchBar!

    var stackViewModel = HomeStackViewModel()
    let router = HomeRouter()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()
    var selectedMessageStack: MessageStack?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRecentMessages()
    }

    func fetchRecentMessages() {
        guard let email = UserCoreData.user?.email else { return }
        router.fetchMessages(userEmail: email) { [weak self] (JSON) in
            guard let messageStacks = JSON["messages"] as? [ [String: Any] ] else { return }

            for stack in messageStacks {
                guard let email = stack["email_address"] as? String,
                      let firstName = stack["first_name"] as? String,
                      let message = stack["message"] as? String,
                      let date = stack["created_at"] as? String,
                      let chatID = stack["chat_id"] as? String else { return }

                let image = (stack["image"] as? String ?? "").data(using: .utf8)?.base64EncodedData() ?? Data()
                guard let userImage = UIImage(data: image) ?? UIImage(named: "defaultUserIcon") else { return }

                let user = User(email: email, firstName: firstName, picture: userImage)
                let newMessage = Message(user: user, message: message, date: date)
                let stack = MessageStack(friends: [:], stack: [newMessage], chatID: chatID)

                self?.stackViewModel.add(stack: stack)
            }
            self?.homeTableView.reloadData()
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToMessageSegue" {
            guard let messageViewController = segue.destination as? MessageViewController,
                  let selectedStack = selectedMessageStack else { return }
            messageViewController.stackViewModel = MessageStackViewModel(chatID: selectedStack.chatID)
        }
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let segue = UnwindSegueFromRight(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }

}

extension HomeViewController {

    /* IBActions */
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) { }

    @IBAction func userTappedProfileButton(_ sender: UIButton) {
        transitioningDelegate = slideInTransitionDelegate
        let userProfileVC = UserProfileViewController(nibName: "UserProfileViewController", bundle: nil)
        userProfileVC.transitioningDelegate = slideInTransitionDelegate
        userProfileVC.modalPresentationStyle = .custom

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            let offsetSize = self.view.frame.size.width*(2.0/3.0)
            self.view.frame.origin.x = offsetSize
        })
        present(userProfileVC, animated: true)
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    // Table View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stackViewModel.msArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIndex = indexPath.row
        let stackObj = stackViewModel.msArr[cellIndex]
        let messageObj = stackObj.stack[0]

        guard let cell = homeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        cell.friendName.text = messageObj.user.firstName
        cell.friendPicture.image = messageObj.user.picture
        cell.mostRecentMessageFromConversation.text = messageObj.message
        cell.date.text = DateConverter.handle(date: messageObj.date)

        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let messageStack = stackViewModel.msArr[indexPath.row]
        selectedMessageStack = messageStack
        return indexPath
    }

}
