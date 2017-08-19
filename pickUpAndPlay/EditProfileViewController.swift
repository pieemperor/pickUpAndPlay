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

    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    
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
                            self.emailTextField.text = Auth.auth().currentUser!.email
                            self.firstNameTextField.text = usersDictionary["firstName"] as? String
                            self.lastNameTextField.text = usersDictionary["lastName"] as? String
                            
                        }//End get data
                    }//End if profilePicURL
                }//End if snapshot.key
            }//End if let userDictionary
        })//End ref.child("users")
    }//End Load user data
}//End EditProfileViewController
