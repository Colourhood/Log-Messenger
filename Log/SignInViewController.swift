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
    
    func setUserInCoreData(username: String) {
        let userCoreData: UserCoreData = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! UserCoreData;
        userCoreData.email = username;
        CoreDataController.saveContext();
        
        let userDefaults = UserDefaults.standard;
        userDefaults.set(username, forKey: "username");
    }
    
    func instantiateHomeView() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");
    }
    
    
    fileprivate func checkTextField() {
        let email = self.emailTextField.text;
        let password = self.passwordTextField.text;
        
        if (!(email?.isEmpty)! || !(password?.isEmpty)!) {
            
            if (self.loginOrSignupTypeText == "Sign Up") {
                let request = LOGHTTP().post(url: "/user/signup", parameters: ["username": email!, "password": password!]);
                request.responseJSON(completionHandler: { (response) in
                    
                    switch (response.result) {
                        case .success(let json):
                            let jsonDict = json as! NSDictionary;
                            
                            if let statusCode = response.response?.statusCode {
                                if (statusCode == 200) {
                                    print("Succesful JSON response: \(json)");
                                    if let username = jsonDict["username"] {
                                        self.setUserInCoreData(username: username as! String);
                                        self.instantiateHomeView();
                                    }
                                } else {
                                    print("Status code error: \(json)")
                                }
                            }
                            
                            break;
                        case .failure(let error):
                            print("There was an error with the sign up response \(error)");
                            break;
                    }
                }).resume();
            } else if (self.loginOrSignupTypeText == "Sign In") {
                let request = LOGHTTP().post(url: "/user/login", parameters: ["username": email!, "password": password!]);
                request.responseJSON(completionHandler: { (response) in
                    
                    switch (response.result) {
                        case .success(let json):
                            let jsonDict = json as! NSDictionary;
                            
                            if let statusCode = response.response?.statusCode {
                                if (statusCode == 200) {
                                    print("Succesful JSON response: \(json)");
                                    if let username = jsonDict["username"] {
                                        self.setUserInCoreData(username: username as! String);
                                        self.instantiateHomeView();
                                    }
                                } else {
                                    print("Status code error: \(json)");
                                }
                            }
                            break;
                        case .failure(let error):
                            print("There was an error with the login response \(error)");
                            break;
                    }
                }).resume();
            }
        }
    }

}

extension SignInViewController: UITextFieldDelegate {
    
    enum TextFieldTags: Int {
        case email = 0,
             password
    }
    
    /* UITextField Delegate Methods*/
    
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
    }
    
}
