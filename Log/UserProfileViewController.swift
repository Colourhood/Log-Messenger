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
    @IBOutlet weak var userProfileNavigationBar: UINavigationItem!

    let userInfoArray = ["Username", "Phone"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.profileTableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: "userProfileTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    @IBAction func userTappedDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileTableViewCell", for: indexPath) as? UserProfileTableViewCell {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = userInfoArray[indexPath.row]
            case 1:
                cell.textLabel?.text = "Settings"
            case 2:
                cell.textLabel?.text = "Log out"
            default:
                cell.textLabel?.text = ""
            }
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            return
        case 1:
            return
        case 2:
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
