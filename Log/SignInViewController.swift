//
//  SignInViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import ImagePicker
import Alamofire

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
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!;
    @IBOutlet weak var passwordTextField: UITextField!;
    @IBOutlet weak var signInButton: UIButton!;
    
    var loginOrSignupTypeText: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let _ = imageButton {
            imageButton.layer.masksToBounds = true;
            imageButton.translatesAutoresizingMaskIntoConstraints = false;
            imageButton.layer.cornerRadius = (imageButton.frame.height / 2);
        }
    }
    
    @IBAction func logUserIn() {
        checkTextField();
    }
    
    @IBAction func chooseButton() {
        let imagePickerController = ImagePickerController();
        imagePickerController.delegate = self;
        imagePickerController.imageLimit = 1;
        present(imagePickerController, animated: true, completion: nil);
    }
    
    func instantiateHomeView() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");
    }
    
    private func handleLogin(parameters: Parameters) {
        SignInController.handleLoginSignUpRequest(url: "/user/login", parameters: parameters, completion: { (json) in
            
            let username = json["username"];
            let image = json["image"];
            let error = json["error"];
            
            if ((username != nil) && (image != nil)) {
                let imageDict = image as! NSDictionary;
                let imageData = NSKeyedArchiver.archivedData(withRootObject: imageDict["data"] as! NSArray);
                
                print("Contents of image data \(imageDict)");
                
                CoreDataController.setUser(username: username as! String, image: imageData as NSData);
                LOGUserDefaults.setUser(username: username as! String);
                self.instantiateHomeView();
            } else if ((username != nil) && (error != nil)) {
                CoreDataController.setUser(username: username as! String, image: nil);
                LOGUserDefaults.setUser(username: username as! String);
                self.instantiateHomeView();
            } else {
                //Error occurred
                print("Error: \(error!)");
            }
            
        });
    }
    
    private func handleSignUp(parameters: Parameters) {
        
        let filename = EnumType.imgf.profilePicture.rawValue;
        let ext = EnumType.ext.PNG.rawValue;
        let directory = EnumType.dir.Images.rawValue;

        let userImageData = ConvertImage.convertUIImageToPNGData(image: (imageButton.imageView?.image!)!);
        LOGFileManager.createFileInDocuments(file: userImageData, fileName: filename, directory: directory);
        
        SignInController.handleLoginSignUpRequest(url: "/user/signup", parameters: parameters, completion: { (json) in
            if let username = json["username"] {
                
                let profileImageURL = LOGFileManager.getFileURLInDocumentsForDirectory(filename: filename, directory: directory);
                let key = "\(filename):\(username).\(ext)";
                
                LOGS3.uploadToS3(key: key, fileURL: profileImageURL, contentType: EnumType.mime.PNG.rawValue, completionHandler: { (result) in
                    if (result != nil) {
                        
                        CoreDataController.setUser(username: username as! String, image: userImageData! as NSData);
                        LOGUserDefaults.setUser(username: username as! String);
                        print(CoreDataController.currentUserCoreData);
                        self.instantiateHomeView();
                    }
                });
            }
        });
    }
    
    fileprivate func checkTextField() {
        let email = emailTextField.text;
        let password = passwordTextField.text;
        
        if (!(email?.isEmpty)! && !(password?.isEmpty)!) {
            let parameters: Parameters = ["username": email!, "password": password!];
            
            if (loginOrSignupTypeText == "Sign Up") {
                handleSignUp(parameters: parameters);
            } else if (loginOrSignupTypeText == "Sign In") {
                handleLogin(parameters: parameters);
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

extension SignInViewController: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {}
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let image: UIImage? = images[0];
        self.dismiss(animated: true) { 
            let imageCropperViewController = RSKImageCropViewController.init(image: image!, cropMode: RSKImageCropMode.circle);
            imageCropperViewController.delegate = self;
            
            self.present(imageCropperViewController, animated: true, completion: nil);
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {}
}

extension SignInViewController: RSKImageCropViewControllerDelegate {
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {}
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        imageButton.setImage(croppedImage, for: .normal);
        self.dismiss(animated: true, completion: nil);
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        imageButton.setImage(croppedImage, for: .normal);
        self.dismiss(animated: true, completion: nil);
    }
}


