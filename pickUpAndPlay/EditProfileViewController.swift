//
//  EditProfileViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/19/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
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
                }
            } else {
                ref.child("users").observe(.childAdded, with: {(snapshot) in
                    if snapshot.key == Auth.auth().currentUser!.uid {
                        if let dictionary = snapshot.value as? [String : AnyObject] {
                            self.picURL = dictionary["photo"] as! String
                        }
                    }
                })
            }
            
            let alertController = UIAlertController(title: "Account Updated", message: "Your account has been successfully updated", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            alertController.addAction(actionOk)
            self.present(alertController, animated: true, completion: nil)
    

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
                                                if let error = error {
                                                    // An error happened.
                                                } else {
                                                    // Account deleted.
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
        ref.child("users").observe(.childAdded, with: {(snapshot) in
            if let usersDictionary = snapshot.value as? [String: AnyObject] {
                if snapshot.key == Auth.auth().currentUser!.uid {
                    
                    
                    let profilePicURL = usersDictionary["photo"] as? String
                    var userProfilePic = UIImage()
                    
                    if profilePicURL != "", profilePicURL != nil , profilePicURL != "none"{
                        
                        let picRef = Storage.storage().reference(forURL: profilePicURL!)
                        
                        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                        picRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                            if let error = error {
                                // Uh-oh, an error occurred!
                                print("The following error occurred - \(error)")
                            } else {
                                // Data for "images/island.jpg" is returned
                                userProfilePic = UIImage(data: data!)!
                            }
                            
                            self.profilePic.image = userProfilePic
                        }//End get data
                    }//End if profilePicURL
                    self.emailTextField.text = Auth.auth().currentUser!.email
                    self.firstNameTextField.text = usersDictionary["firstName"] as? String
                    self.lastNameTextField.text = usersDictionary["lastName"] as? String
                }//End if snapshot.key
            }//End if let userDictionary
        })//End ref.child("users")
    }//End Load user data
}//End EditProfileViewController
