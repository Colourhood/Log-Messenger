//
//  HomeViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var recentMessages: [MessageStack] = []
    var selectedMessageStack: MessageStack?

    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    /* UI-IBOutlets */
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var friendSearchBar: UISearchBar!

    /* IBActions */
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let segue = UnwindSegueFromRight(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchRecentMessages()
    }

    func fetchRecentMessages() {
        HomeController.getRecentMessages { [weak self] (responseData) in
            guard let `self` = self else { return }

            for messagePackets in responseData {
                var conversation = MessageStack()
                var friendProfile: User?
                var image: UIImage?

                let recentMessageDict = messagePackets as? [String: Any]

                if let email = recentMessageDict?["email_address"] as? String,
                   let firstName = recentMessageDict?["first_name"] as? String,
                   let message = recentMessageDict?["message"] as? String,
                   let date = recentMessageDict?["created_at"] as? String,
                   let chatID = recentMessageDict?["chat_id"] as? String {

                    let imageString: String? = recentMessageDict?["image"] as? String

                    if let imageString = imageString {
                        let imageData = NSData(base64Encoded: imageString, options: NSData.Base64DecodingOptions(rawValue: NSData.Base64DecodingOptions.RawValue(0)))
                        image = UIImage(data: imageData! as Data)!
                    } else {
                        image = UIImage(named: "defaultUserIcon")
                    }

                    friendProfile = User(email: email, firstName: firstName, picture: image)

                    if let friendProfile = friendProfile {
                        let recentMessage = Message(user: friendProfile, message: message, date: date)
                        conversation.setFriends(friendProfile: friendProfile)
                        conversation.setStackOfMessages(stack: [recentMessage])
                        conversation.setChatID(chatIdentifier: chatID)
                        self.recentMessages.append(conversation)
                    }
                }
            }

            DispatchQueue.main.async {
                self.homeTableView.reloadData()
            }
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToMessageSegue" {
            if let messageViewController = segue.destination as? MessageViewController {
                messageViewController.friendConversation = selectedMessageStack
            }
        }
    }

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
        return recentMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendConversationData = recentMessages[indexPath.row]

        let friendName = friendConversationData.getFriendProfile()?.getName()
        let userImage = friendConversationData.getFriendProfile()?.picture
        let mostRecentMessage = friendConversationData.getStackOfMessages()[0]?.getMessage()
        let date = friendConversationData.getStackOfMessages()[0]?.getDate()

        let cell = homeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell
        cell?.friendName.text = friendName
        cell?.friendPicture.image = userImage
        cell?.mostRecentMessageFromConversation.text = mostRecentMessage
        cell?.date.text = DateConverter.handleDate(date: date)

        return cell!
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let friendMessageStack = recentMessages[indexPath.row]
        selectedMessageStack = friendMessageStack
        return indexPath
    }

}
