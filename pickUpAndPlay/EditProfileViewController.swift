//
//  EditProfileViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/19/17.
//  Copyright © 2017 Dakota Cowell. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var uuid = UUID()
    var picWasSelected = false
    var picURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        loadUserData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        if firstNameTextField.text != "", lastNameTextField.text != "", emailTextField.text != "" {
            let ref = Database.database().reference()

            spinner.startAnimating()
            if picWasSelected {
                //Get PNG representation of the image they chose
                let imageData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)!
                
                // Get a reference to the profilePics folder where we'll store our photos
                let picHandle = Storage.storage().reference().child("profilePics")
                
                // Get a reference to store the file as uuid
                let photoRef = picHandle.child(self.uuid.uuidString)
                
                // Upload file to Firebase Storage
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                photoRef.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
                    
                    // When the image has successfully uploaded, we get it's download URL
                    self.picURL = (snapshot.metadata?.downloadURL()?.absoluteString)!
                    
                    Auth.auth().currentUser?.updateEmail(to: self.emailTextField.text!) { (error) in
                        let post = [ "firstName" : self.firstNameTextField.text!,
                                     "lastName" : self.lastNameTextField.text!,
                                     "photo" : self.picURL
                        ]
                        
                        let profileUpdates = ["users/\(Auth.auth().currentUser!.uid)": post]
                        ref.updateChildValues(profileUpdates)
                    }
                    self.spinner.stopAnimating()
                    let alertController = UIAlertController(title: "Account Updated", message: "Your account has been successfully updated", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK",
                                                 style: .default,
                                                 handler: nil) //You can use a block here to handle a press on this button
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)
                    self.goToProfile()
                }
            } else {
                ref.child("users").observe(.childAdded, with: {(snapshot) in
                    if snapshot.key == Auth.auth().currentUser!.uid {
                        if let dictionary = snapshot.value as? [String : AnyObject] {
                            self.picURL = dictionary["photo"] as! String
                            
                            Auth.auth().currentUser?.updateEmail(to: self.emailTextField.text!) { (error) in
                                let post = [ "firstName" : self.firstNameTextField.text!,
                                             "lastName" : self.lastNameTextField.text!,
                                             "photo" : self.picURL
                                ]
                                
                                let profileUpdates = ["users/\(Auth.auth().currentUser!.uid)": post]
                                ref.updateChildValues(profileUpdates)
                                self.spinner.stopAnimating()
                                self.goToProfile()
                            }
                        }
                    }
                })
            }
        } else {
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
        }
    }
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Delete Account?", message: "Clicking confirm will permanently delete your account", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel",
                                     style: .cancel,
                                     handler: nil) //You can use a block here to handle a press on this button
        let actionDelete = UIAlertAction(title: "Confirm",
                                         style: .destructive,
                                         handler: { UIAlertAction in
                                            Auth.auth().currentUser?.delete { error in
                                                if error != nil {
                                                    self.presentDeleteError()
                                                } else {
                                                    // Account deleted.
                                                    self.goToLogin()
                                                }
                                            }
        }) //You can use a block here to handle a press on this button
        alertController.addAction(actionCancel)
        alertController.addAction(actionDelete)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setupButtons() {
        deleteAccountButton.layer.cornerRadius = 10.0
        firstNameTextField.layer.cornerRadius = 10.0
        lastNameTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        updateProfileButton.layer.cornerRadius = 10.0
        spinner.layer.cornerRadius = 10.0
        let transparentBlack = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        spinner.backgroundColor = transparentBlack
    }
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get local file URLs
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set profilePic to display the selected image.
        profilePic.image = image
        
        picWasSelected = true
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func loadUserData() {
        let ref = Database.database().reference()
        spinner.startAnimating()
        ref.child("users").observe(.childAdded, with: {(snapshot) in
            if let usersDictionary = snapshot.value as? [String: AnyObject] {
                if snapshot.key == Auth.auth().currentUser!.uid {
                    
                    let profilePicURL = usersDictionary["photo"] as? String
                    if profilePicURL != "", profilePicURL != nil , profilePicURL != "none"{
                        let url = URL(string: profilePicURL!)
                        let data = try? Data(contentsOf: url!)
                        self.profilePic.image = UIImage(data : data!)
                        
                   }//End if profilePicURL
                    self.emailTextField.text = Auth.auth().currentUser!.email
                    self.firstNameTextField.text = usersDictionary["firstName"] as? String
                    self.lastNameTextField.text = usersDictionary["lastName"] as? String
                }//End if snapshot.key
                self.spinner.stopAnimating()
            }//End if let userDictionary
        })//End ref.child("users")
    }//End Load user data
    
    func goToProfile(){
        performSegue(withIdentifier: "unwindToProfile", sender: nil)
    }
    
    func goToLogin() {
        performSegue(withIdentifier: "logOut", sender: nil)
    }
    
    func presentDeleteError(){
        let alertController = UIAlertController(title: "Problem Deleting Account", message: "Cannot delete account. Log out and then try again. ", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Okay",
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
}//End EditProfileViewController
