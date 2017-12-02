//
//  UserProfileViewController.swift
//  Log
//
//  Created by Katherine Li on 10/17/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData

class UserProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profileImage: ProfileImageView!
    @IBOutlet weak var profileName: UILabel!

    let userInfoArray = [
        ["Title": "Settings", "Image": #imageLiteral(resourceName: "setting")],
        ["Title": "Log Out", "Image": #imageLiteral(resourceName: "out")]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        profileTableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: "userProfileTableViewCell")

        if let image = UserCoreDataController.getUserProfile()?.image {
            profileImage.image = UIImage(data: image as Data)
        }
        if let name = UserCoreDataController.getUserProfile()?.firstName {
            profileName.text = name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("UserProfileTableViewCell", owner: self, options: nil)?.first as? UserProfileTableViewCell
        cell?.labelName?.text = userInfoArray[indexPath.row]["Title"] as? String
        cell?.cellImage.image = userInfoArray[indexPath.row]["Image"] as? UIImage
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        case 1:
            // Log out
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
                if appDelegate.window?.rootViewController != initialVC {
                    appDelegate.window?.rootViewController = initialVC
                }
                self.cleanCoreData()
                self.dismiss(animated: false, completion: nil)
                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let profileCell = cell as? UserProfileTableViewCell
        profileCell?.animateBounce(delay: Double(indexPath.row+1))
    }

}

extension UserProfileViewController {
    // Clean Core Data. Deleting all data in entity User
    func cleanCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserCoreData.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try CoreDataBP.getContext().execute(batchDeleteRequest)
        } catch {
            // Error Handling
            print("😂 Something goes wrong. I can't clean the core data. ")
        }
    }
}
