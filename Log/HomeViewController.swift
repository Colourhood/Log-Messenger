//
//  HomeViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/23/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData

class HomeCollectionViewController {

}

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var friendPicture: UIImageView!;
    @IBOutlet weak var friendName: UILabel!;
    @IBOutlet weak var mostRecentMessageFromConversation: UILabel!;
    
}

class HomeViewController: UIViewController {
    @IBOutlet weak var HomeTableView: UITableView!;
    
    var selectedConversation: MessageStack?;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

//     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "HomeToMessageSegue") {
            print("This segue was called");
            
            if let messageViewController = segue.destination as? MessageViewController {
                messageViewController.friendConversation = self.selectedConversation;
            }
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    var currentUserCoreData: [UserCoreData] {
        var userResults: [UserCoreData]?;
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest();
        do {
            userResults = try CoreDataController.getContext().fetch(fetchRequest);
        } catch {
        }
        return userResults!;
    }
    
    //Table View Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageDataExample.getConversations().count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friendConversationData = MessageDataExample.getConversations()[indexPath.row];
        
        let friendName = friendConversationData.conversationWithFriend?.getFullName();
        let mostRecentMessage = friendConversationData.messageStack.last?.message;
        let userImage = friendConversationData.conversationWithFriend?.getPicture();
        
        var cell: HomeTableViewCell?;
        
        cell = self.HomeTableView.dequeueReusableCell(withIdentifier: "Friend Conversation Cell", for: indexPath) as? HomeTableViewCell;
        cell?.friendName.text = friendName;
        cell?.friendPicture.image = userImage;
        cell?.mostRecentMessageFromConversation.text = mostRecentMessage;
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print("Will select row");
        
        let friendConversationData = MessageDataExample.getConversations()[indexPath.row];
        self.selectedConversation = friendConversationData;
        
        return indexPath;
    }

}
