//
//  SignInViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData

class InitialViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!;
    @IBOutlet weak var signInButton: UIButton!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SignUpSegue") {
            print("Sign up segue was called");
            if let signInViewController = segue.destination as? SignInViewController {
                signInViewController.loginOrSignupTypeText = "Sign Up";
            }
        } else if (segue.identifier == "SignInSegue") {
            print("Sign in segue was called");
            if let signinViewController = segue.destination as? SignInViewController {
                signinViewController.loginOrSignupTypeText = "Sign In";
            }
        }
    }
}

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var passwordTextField: UITextField!;
    @IBOutlet weak var signInButton: UIButton!;
    @IBOutlet weak var loginOrSignupLabel: UILabel?;
    
    var loginOrSignupTypeText: String?;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("What was chosen and it's value:  \(loginOrSignupTypeText!)");
        loginOrSignupLabel?.text = self.loginOrSignupTypeText;
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logUserIn() {
        checkTextField();
    }
    
    
    fileprivate func checkTextField() {
        let email = self.emailTextField.text;
        let password = self.passwordTextField.text;
        
        if (!(email?.isEmpty)! ||
            !(password?.isEmpty)!) {
            
            let userCoreData: UserCoreData = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! UserCoreData;
//            Attempt to sign up or login targeting the server
//            save user details based from server response
//            userCoreData.email = self.emailTextField.text;
            
            if (self.loginOrSignupTypeText == "Sign Up") {
                //Create a request to create a new user from the log_node_database
                LOGHTTP().post(url: "/user/createUser", parameters: ["username": email!, "password": password!]);
            } else if (self.loginOrSignupTypeText == "Sign In") {
                //Create a request to log in possible existing user
            }
            
            CoreDataController.saveContext();
            
//            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
//            let storyboard = UIStoryboard(name: "Main", bundle: nil);
//            appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");
        }
    }

}

extension SignInViewController: UITextFieldDelegate {
    
    enum TextFieldTags: Int {
        case email = 0, password
    }
    
    /* UITextField Delegate Methods*/
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    } // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    } // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch(textField.tag) {
            case TextFieldTags.email.rawValue:
                let nextResponder: UIResponder!;
                nextResponder = textField.superview?.viewWithTag(TextFieldTags.password.rawValue);
                nextResponder.becomeFirstResponder();
                break;
            case TextFieldTags.password.rawValue:
                checkTextField();
                break;
            
            default:
            break;
        }
        return true;
    } // called when 'return' key pressed. return NO to ignore.
    
}
