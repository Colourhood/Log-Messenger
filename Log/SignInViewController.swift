//
//  SignInViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController {
    
    @IBOutlet weak var signInTextField: UITextField!;
    @IBOutlet weak var signInButton: UIButton!;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logUserIn() {
        checkTextField();
    }
    
    
    fileprivate func checkTextField() {
        if (!(self.signInTextField.text?.isEmpty)!) {
            
            let userCoreData: UserCoreData = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataController.getContext()) as! UserCoreData;
            userCoreData.email = self.signInTextField.text;
            
            CoreDataController.saveContext();
            
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MessageViewController");
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignInViewController: UITextFieldDelegate {
    
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
        checkTextField();
        return true;
    } // called when 'return' key pressed. return NO to ignore.
    
}
