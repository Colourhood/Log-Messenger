//
//  SignInViewController.swift
//  Log
//
//  Created by Andrei Villasana on 8/22/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import UIKit
import Lottie
import ImagePicker

class SignInViewController: UIViewController {

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var lottieBackView: UIView!

    var loginOrSignupTypeText: String?
    let router = SignInRouter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let imageButton = imageButton {
            imageButton.layer.masksToBounds = true
            imageButton.translatesAutoresizingMaskIntoConstraints = false
            imageButton.layer.cornerRadius = (imageButton.frame.height / 2)
        }

        let animatedButton = LOTAnimationView(name: "BackButton")
        animatedButton.frame = lottieBackView.bounds
        animatedButton.loopAnimation = true
        animatedButton.play()
        lottieBackView.addSubview(animatedButton)
    }

    @IBAction func logUserIn() {
        checkTextField()
    }

    @IBAction func chooseButton() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }

    func instantiateHomeView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
    }

}

extension SignInViewController {

    // API - Networking

    private func login(param: [String: Any]) {
        router.handleLogin(param: param) { [weak self] (JSON) in
            guard let email = JSON["user_email"] as? String,
                  let name = JSON["first_name"] as? String,
                  let image = (JSON["image"] as? String)?.data(using: .utf8) ?? UIImage(named: "defaultUserIcon")?.dataJPEG(),
                  let imageData = NSData(base64Encoded: image, options: NSData.Base64DecodingOptions(rawValue: 0)) ?? image as? NSData else { return }
            UserCoreData.set(email: email, name: name, image: imageData)
            self?.instantiateHomeView()
        }
    }

    private func signup(param: [String: Any]) {
        let filename = Constants.profilePicture
        let directory = Constants.Images

        guard let image = imageButton.imageView?.image?.dataJPEG() else { return }
        LOGFileManager.save(file: image, fileName: filename, directory: directory)

        router.handleSignUp(param: param) { (JSON) in
            guard let email = JSON["user_email"] as? String,
                  let imageURL = LOGFileManager.fetchURL(filename: filename, directory: directory) else { return }

            let key = "\(filename):\(email)"
            let imageData = NSData(data: image)

            LOGS3.uploadToS3(key: key, fileURL: imageURL, completionHandler: { (result) in
                guard result != nil else { return }
                UserCoreData.set(email: email, name: "Name", image: imageData)
                self.instantiateHomeView()
            })
        }
    }

    fileprivate func checkTextField() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if !email.isEmpty && !password.isEmpty {
                let param = ["user_email": email, "password": password]

                if loginOrSignupTypeText == "Sign Up" {
                    signup(param: param)
                } else if loginOrSignupTypeText == "Sign In" {
                    login(param: param)
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

    /* UITextField Delegate Methods */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case TextFieldTags.email.rawValue:
            let nextResponder: UIResponder!
            nextResponder = textField.superview?.viewWithTag(TextFieldTags.password.rawValue)
            nextResponder.becomeFirstResponder()
        case TextFieldTags.password.rawValue:
            checkTextField()
        default:
            break
        }
        return true
    }

}

extension SignInViewController: ImagePickerDelegate {

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        let image: UIImage? = images[0]
        self.dismiss(animated: true) {
            let imageCropperViewController = RSKImageCropViewController.init(image: image!, cropMode: RSKImageCropMode.circle)
            imageCropperViewController.delegate = self

            self.present(imageCropperViewController, animated: true, completion: nil)
        }
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    }
}

extension SignInViewController: RSKImageCropViewControllerDelegate {

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        imageButton.setImage(croppedImage, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }

    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        imageButton.setImage(croppedImage, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
}
