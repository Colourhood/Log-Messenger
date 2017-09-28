//
//  HomeViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit

class HomeCollectionViewController {
}

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var friendPicture: UIImageView!;
    @IBOutlet weak var friendName: UILabel!;
    @IBOutlet weak var mostRecentMessageFromConversation: UILabel!;
    
}

class HomeViewController: UIViewController {
    @IBOutlet weak var HomeTableView: UITableView!;
    
    var recentMessages: [MessageStack] = [];
    var selectedConversationWithFriend: LOGUser?;
    
    //#MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HomeController.getRecentMessages() { (responseData) in
            guard let username = CoreDataController.getUserProfile()?.email else {
                return;
            }
            
            for messagePackets in responseData {
                guard let conversationArray = messagePackets as? NSArray else {
                    return;
                }
                guard let recentMessageDict = conversationArray[0] as? NSDictionary else {
                    return;
                }
                
                guard let sentBy = recentMessageDict["sentBy"] as? String,
                      let sentTo = recentMessageDict["sentTo"] as? String,
                      let message = recentMessageDict["message"] as? String else {
                    return
                }
                
                var conversation = MessageStack();
                var friendProfile: LOGUser?;
                
                switch (username) {
                    case sentBy:
                        friendProfile = LOGUser.init(handle: sentTo, email: sentTo, firstName: sentTo, lastName: sentTo, picture: UIImage(named: "defaultUserIcon"));
                        break;
                    case sentTo:
                        friendProfile = LOGUser.init(handle: sentBy, email: sentBy, firstName: sentBy, lastName: sentBy, picture: UIImage(named: "defaultUserIcon"));
                        break;
                    default:
                        break;
                }
                
                let recentMessage = Message.init(messageSender: friendProfile, message: message, dateSent: Date.init());
                conversation.setFriendProfile(friendProfile: friendProfile);
                conversation.setStackOfMessages(stack: [recentMessage]);
                
                self.recentMessages.append(conversation);
                self.HomeTableView.reloadData();
            }
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HomeToMessageSegue") {
            if let messageViewController = segue.destination as? MessageViewController {
                var messageStack = MessageStack();
                messageStack.setFriendProfile(friendProfile: selectedConversationWithFriend);
                messageViewController.friendConversation = messageStack;
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Table View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentMessages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendConversationData = recentMessages[indexPath.row];
//        let friendName = friendConversationData.conversationWithFriend?.getFullName();
        let friendEmail = friendConversationData.getFriendProfile()?.getEmail();
        let userImage = friendConversationData.getFriendProfile()?.getPicture();
        let mostRecentMessage = friendConversationData.getStackOfMessages()[0].getMessage();
        
        var cell: HomeTableViewCell?;
        cell = HomeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell;
        cell?.friendName.text = friendEmail;
        cell?.friendPicture.image = userImage;
        cell?.mostRecentMessageFromConversation.text = mostRecentMessage;
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let friendConversationData = recentMessages[indexPath.row];
        selectedConversationWithFriend = friendConversationData.getFriendProfile();
        
        return indexPath;
    }

}
