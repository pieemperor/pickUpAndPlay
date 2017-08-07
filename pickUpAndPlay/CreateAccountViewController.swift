//
//  CreateAccountViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 6/18/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//
//TODO: Make profile pics round
//TODO: Give feedback if password isn't long enough or doesn't match or if things arent filled out

import UIKit
import Firebase

class CreateAccountViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    var ref: DatabaseReference! = Database.database().reference()
    var profilePicURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTextBoxes()
    }

    @IBAction func createAccount(_ sender: UIButton) {
        
        if let fn = firstNameTextField.text, let ln = lastNameTextField.text, let e = emailTextField.text, let pw = passwordTextField.text, let cpw = confirmPasswordTextField.text {
            if pw == cpw, pw.characters.count > 6 {
                Auth.auth().createUser(withEmail: e, password: pw, completion: { (user, error) in
                    
                    
                    // Check that user isn't nil
                    if let u = user {
                        
                        //Save user's display name
                        self.ref.child("users").child(u.uid).setValue(["firstName": fn, "lastName": ln, "photo": self.profilePicURL])
                        
                        // User is found, go to home screen
                        self.performSegue(withIdentifier: "goToMap", sender: self)
                    }
                    else {
                        // Error: check error and show message
                    }
                })

                }
            }
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
        roundImage()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        
        // Get local file URLs
        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        let imageData = UIImagePNGRepresentation(image)!
        guard let _: NSURL = info[UIImagePickerControllerReferenceURL] as? NSURL else { return }
        
        // Get a reference to the location where we'll store our photos
        let picHandle = Storage.storage().reference().child("profilePics")
        
        // Get a reference to store the file at chat_photos/<FILENAME>
        let photoRef = picHandle.child("\(Auth.auth().currentUser!.uid).png")
        
        // Upload file to Firebase Storage
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        photoRef.putData(imageData, metadata: metadata).observe(.success) { (snapshot) in
            // When the image has successfully uploaded, we get it's download URL
            let text = snapshot.metadata?.downloadURL()?.absoluteString
            // Set the download URL to the message box, so that the user can send it to the database
            self.profilePicURL = text!
        }
        
        /*
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }*/
        
        // Set photoImageView to display the selected image.
        profilePic.image = image
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setupTextBoxes() {
        firstNameTextField.layer.cornerRadius = 10.0
        lastNameTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        confirmPasswordTextField.layer.cornerRadius = 10.0
        createAccountButton.layer.borderWidth = 1.0
        createAccountButton.layer.borderColor = UIColor.white.cgColor
        createAccountButton.layer.cornerRadius = 10.0
        
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
    
    func roundImage() {
        profilePic.layer.cornerRadius = profilePic.frame.height/2
    }
    
    
    func uploadProfilePic() {
        _ = Storage.storage().reference().child("profilePics\(Auth.auth().currentUser!.uid).jpg")
        
    }
    
}
