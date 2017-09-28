//
//  SignInViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import ImagePicker

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController");
        }
    }
    
    private func handleLogin(parameters: [String: Any]) {
        SignInController.handleLoginSignUpRequest(url: "/user/login", parameters: parameters, completion: { (json) in
            
            if let username = json["username"] as? String {
                if let image = json["image"] as? String {
                    if let imageData = NSData(base64Encoded: image, options: NSData.Base64DecodingOptions(rawValue: NSData.Base64DecodingOptions.RawValue(0))) {
                        CoreDataController.setUser(username: username, image: imageData);
                        LOGUserDefaults.setUser(username: username);
                        self.instantiateHomeView();
                    }
                } else {
                    guard let image = UIImage(named: "defaultUserIcon") else {
                        return;
                    }
                    let defaultImageData = ConvertImage.convertUIImageToPNGData(image: image)! as NSData;
                    CoreDataController.setUser(username: username, image: defaultImageData);
                    LOGUserDefaults.setUser(username: username);
                    self.instantiateHomeView();
                }
            } else {
                //Error occurred
                if let error = json["error"] as? String {
                    print("Error: \(error)");
                }
            }
            
        });
    }
    
    private func handleSignUp(parameters: [String: Any]) {
        let filename = EnumType.imgf.profilePicture.rawValue;
        let ext = EnumType.ext.PNG.rawValue;
        let directory = EnumType.dir.Images.rawValue;

        guard let image = imageButton.imageView?.image else { return; }
        guard let userImageData = ConvertImage.convertUIImageToPNGData(image: image) else { return; }
        LOGFileManager.createFileInDocuments(file: userImageData, fileName: filename, directory: directory);
        
        SignInController.handleLoginSignUpRequest(url: "/user/signup", parameters: parameters, completion: { (json) in
            if let username = json["username"] as? String {
                let profileImageURL = LOGFileManager.getFileURLInDocumentsForDirectory(filename: filename, directory: directory);
                let key = "\(filename):\(username).\(ext)";
                
                LOGS3.uploadToS3(key: key, fileURL: profileImageURL, contentType: EnumType.mime.PNG.rawValue, completionHandler: { (result) in
                    if let _ = result {
                        CoreDataController.setUser(username: username, image: userImageData as NSData);
                        LOGUserDefaults.setUser(username: username);
                        print(CoreDataController.currentUserCoreData);
                        self.instantiateHomeView();
                    }
                });
            }
        });
    }
    
    fileprivate func checkTextField() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if (!email.isEmpty && !password.isEmpty) {
                let parameters = ["username": email, "password": password];
                if (loginOrSignupTypeText == "Sign Up") {
                    handleSignUp(parameters: parameters);
                } else if (loginOrSignupTypeText == "Sign In") {
                    handleLogin(parameters: parameters);
                }
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


