//
//  InitialViewController.swift
//  Log
//
//  Created by Andrei Villasana on 12/2/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

class InitialViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }

    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let segue = UnwindSegueFromRight(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignUpSegue" {
            print("Sign up segue was called")
            if let signInViewController = segue.destination as? SignInViewController {
                signInViewController.loginOrSignupTypeText = "Sign Up"
            }
        } else if segue.identifier == "SignInSegue" {
            print("Sign in segue was called")
            if let signinViewController = segue.destination as? SignInViewController {
                signinViewController.loginOrSignupTypeText = "Sign In"
            }
        }
    }

}
