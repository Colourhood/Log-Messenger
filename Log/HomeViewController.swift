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
    var selectedConversation: MessageStack?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HomeController.getRecentMessages { (responseData) in
            print("Data: \(responseData)");
            
            for messagePackets in responseData {
                let conversationArray = messagePackets as! NSArray;
                let recentMessageDict = conversationArray[0] as! NSDictionary;
                
                let sentBy = recentMessageDict.object(forKey: "sentBy") as! String;
                let sentTo = recentMessageDict.object(forKey: "sentTo") as! String;
                let message = recentMessageDict.object(forKey: "message") as! String;
                
                let conversation = MessageStack();
                
                switch (HomeController.username!) {
                    case sentBy:
                        conversation.conversationWithFriend = LOGUser.init(handle: sentTo, email: sentTo, firstName: sentTo, lastName: sentTo, picture: UIImage(named: "defaultUserIcon"));
                        conversation.messageStack.append(Message.init(messageSender: conversation.conversationWithFriend, message: message, dateSent: MessageDataExample.date));
                        break;
                    case sentTo:
                        conversation.conversationWithFriend = LOGUser.init(handle: sentBy, email: sentBy, firstName: sentBy, lastName: sentBy, picture: UIImage(named: "defaultUserIcon"));
                        conversation.messageStack.append(Message.init(messageSender: conversation.conversationWithFriend, message: message, dateSent: MessageDataExample.date));
                        break;
                    default:
                        break;
                }
                
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
                messageViewController.friendConversation = self.selectedConversation;
            }
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    //Table View Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentMessages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friendConversationData = self.recentMessages[indexPath.row];
//        let friendName = friendConversationData.conversationWithFriend?.getFullName();
        let friendEmail = friendConversationData.conversationWithFriend?.getEmail();
        let mostRecentMessage = friendConversationData.messageStack[0].message;
        let userImage = friendConversationData.conversationWithFriend?.getPicture();
        
        var cell: HomeTableViewCell?;
        cell = self.HomeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell;
        cell?.friendName.text = friendEmail;
        cell?.friendPicture.image = userImage;
        cell?.mostRecentMessageFromConversation.text = mostRecentMessage;
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let friendConversationData = self.recentMessages[indexPath.row];
        self.selectedConversation = friendConversationData;
        
        return indexPath;
    }

}
