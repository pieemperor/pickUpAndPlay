//
//  CreateAccountViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 6/18/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK: variables
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    let ref = Database.database().reference()
    var profilePicURL : String? = "https://firebasestorage.googleapis.com/v0/b/pickupandplay-67953.appspot.com/o/image_uploaded_from_ios.jpg?alt=media&token=a931d6aa-7945-471e-aa40-cfb3acf463b0"
    let uuid = UUID()
    var didSelectImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextBoxes()

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.clipsToBounds = true
    }
    
    @IBAction func createAccount(_ sender: UIButton) {
        UIView.animate(withDuration: 0.50) { () -> Void in
            let firstView = self.stackView.arrangedSubviews[0]
            firstView.isHidden = false
        }
        
        //If all fields are not empty, the password fields are equal, and the password field is longer than 6 characters, create an account
        if let fn = firstNameTextField.text, let ln = lastNameTextField.text, let e = emailTextField.text, let pw = passwordTextField.text, let cpw = confirmPasswordTextField.text, fn != "", ln != "", e != "", pw != "", cpw != "" {
            setDefaultBorderWidths()
            if pw == cpw {
                setDefaultBorderWidths()
                if pw.count > 5  {
                    setDefaultBorderWidths()
                    spinner.startAnimating()
                    Auth.auth().createUser(withEmail: e, password: pw, completion: { (user, error) in
                        
                        if self.didSelectImage {
                            
                        let resizedImage = self.resizeImage(image: self.profilePic.image!, newWidth: 120.0)
                            
                        //Get PNG representation of the image they chose
                        let imageData = resizedImage.jpegData(compressionQuality: 1.0)!
                        
                        // Get a reference to the profilePics folder where we'll store our photos
                        let picHandle = Storage.storage().reference().child("profilePics")
                        
                        // Get a reference to store the file as uuid
                        let photoRef = picHandle.child(self.uuid.uuidString)
                        
                        // Upload file to Firebase Storage
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpg"
                        photoRef.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
                            
                            // When the image has successfully uploaded, we get it's download URL
                            photoRef.downloadURL(completion: {url, error in
                                if let err = error {
                                    print("An error occured when attempting to retrieve URL - ", err)
                                } else {
                                    self.profilePicURL = url?.absoluteString
                                }
                            })
                            
                            //Old version of Firebase Storage - This code doesn't work any more. The
                            //self.profilePicURL = snapshot.metadata?.downloadURL()?.absoluteString
                            
                            // Set the download URL to the message box, so that the user can send it to the database
                            
                            // Check that user isn't nil
                            if let u = user {
                                //Save user's display name
                                self.ref.child("users").child(u.user.uid).setValue(["firstName": fn, "lastName": ln, "photo": self.profilePicURL!])
                                
                                self.spinner.stopAnimating()
                                // User is found, go to home screen
                                self.performSegue(withIdentifier: "goToMap", sender: self)
                            } else {
                                let alertController = UIAlertController(title: "Email Taken", message: "That email is already in use by another account", preferredStyle: .alert)
                                let actionOk = UIAlertAction(title: "OK",
                                                             style: .default,
                                                             handler: nil) //You can use a block here to handle a press on this button
                                
                                alertController.addAction(actionOk)
                                self.present(alertController, animated: true, completion: nil)
                                self.emailTextField.layer.borderWidth = 1.0
                                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                                // Error: check error and show message
                            }
                        }//End photo completion handler
                        } else {
                            if let u = user {
                                //Save user's display name
                                self.ref.child("users").child(u.user.uid).setValue(["firstName": fn, "lastName": ln, "photo": self.profilePicURL!])
                                
                                self.spinner.stopAnimating()
                                // User is found, go to home screen
                                self.performSegue(withIdentifier: "goToMap", sender: self)
                            } else {
                                let alertController = UIAlertController(title: "Email Taken", message: "That email is already in use by another account", preferredStyle: .alert)
                                let actionOk = UIAlertAction(title: "OK",
                                                             style: .default,
                                                             handler: nil) //You can use a block here to handle a press on this button
                                
                                alertController.addAction(actionOk)
                                self.present(alertController, animated: true, completion: nil)
                                self.emailTextField.layer.borderWidth = 1.0
                                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                                // Error: check error and show message
                            }
                        }
                    })//End Firebase createUser
                }//End if password field is > 6
                else {
                    let alertController = UIAlertController(title: "Invalid Password", message: "Password must be at least 6 characters long", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)
                    self.passwordTextField.layer.borderWidth = 1.0
                    self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                }
            }//End if password fields are equal
            else {
                let alertController = UIAlertController(title: "Passwords Not Equal", message: "The password fields are not equal", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil) //You can use a block here to handle a press on this button
                
                alertController.addAction(actionOk)
                self.present(alertController, animated: true, completion: nil)
                self.confirmPasswordTextField.layer.borderWidth = 1.0
                self.confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.passwordTextField.layer.borderWidth = 1.0
                self.passwordTextField.layer.borderColor = UIColor.red.cgColor
            }
            }//End if fields are not empty
        else {
            let alertController = UIAlertController(title: "Empty Text Field", message: "All text fields are required", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            self.present(alertController, animated: true, completion: nil)
            
            //Checks each text field to make sure they're not empty. If they are, highlight in red
            if firstNameTextField.text == "" {
                self.firstNameTextField.layer.borderColor = UIColor.red.cgColor
                self.firstNameTextField.layer.borderWidth = 1.0
            } else {
                self.firstNameTextField.layer.borderWidth = 0.0
            }
            
            if lastNameTextField.text == "" {
                self.lastNameTextField.layer.borderColor = UIColor.red.cgColor
                self.lastNameTextField.layer.borderWidth = 1.0
            } else {
                self.lastNameTextField.layer.borderWidth = 0.0
            }
            
            if emailTextField.text == "" {
                self.emailTextField.layer.borderColor = UIColor.red.cgColor
                self.emailTextField.layer.borderWidth = 1.0
            } else {
                self.emailTextField.layer.borderWidth = 0.0
            }
            
            if passwordTextField.text == "" {
                self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self.passwordTextField.layer.borderWidth = 1.0
            } else {
                self.passwordTextField.layer.borderWidth = 0.0
            }
            
            if confirmPasswordTextField.text == "" {
                self.confirmPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.confirmPasswordTextField.layer.borderWidth = 1.0
            } else {
                self.confirmPasswordTextField.layer.borderWidth = 0.0
            }
        }
        }//End createAccount

    @IBAction func selectProfilePicFromLibrary(_ sender: UITapGestureRecognizer) {
        firstNameTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        // Get local file URLs
        guard let image: UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set profilePic to display the selected image.
        profilePic.image = image
        didSelectImage = true
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func setupTextBoxes() {
        firstNameTextField.layer.cornerRadius = 10.0
        lastNameTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        confirmPasswordTextField.layer.cornerRadius = 10.0
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.borderColor = UIColor.white.cgColor
        createAccountButton.layer.cornerRadius = 10.0
        spinner.layer.cornerRadius = 10.0
        let transparentBlack = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        spinner.backgroundColor = transparentBlack
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    //MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == firstNameTextField.tag {
            lastNameTextField.becomeFirstResponder()
        } else if textField.tag == lastNameTextField.tag {
            emailTextField.becomeFirstResponder()
        } else if textField.tag == emailTextField.tag {
            passwordTextField.becomeFirstResponder()
        } else if textField.tag == passwordTextField.tag {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField.tag == confirmPasswordTextField.tag {
            confirmPasswordTextField.resignFirstResponder()
            createAccount(UIButton())
        } else {
            print("That is not a selectable text field")
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.50) { () -> Void in
            let firstView = self.stackView.arrangedSubviews[0]
            firstView.isHidden = true
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.50) { () -> Void in
            let firstView = self.stackView.arrangedSubviews[0]
            firstView.isHidden = false
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func setDefaultBorderWidths() {
        self.firstNameTextField.layer.borderWidth = 0.0
        self.lastNameTextField.layer.borderWidth = 0.0
        self.emailTextField.layer.borderWidth = 0.0
        self.passwordTextField.layer.borderWidth = 0.0
        self.confirmPasswordTextField.layer.borderWidth = 0.0
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
