//
//  LoginViewController.swift
//  pickUpAndPlay
//
//  Created by Caleb Mitcler on 5/9/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//
//tutorial for custom auth login
//https://www.youtube.com/watch?v=asKXHVUZiIY&t=869s
//facebook login 
//https://firebase.google.com/docs/auth/ios/facebook-login

//TODO: Test Facebook Login
//TODO: Create Loading animation
//TODO: figure out how to skip login in AppDelegate if they are already logged in


import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //labels and textfields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fbSignInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var wrongLoginText: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Check to see if user is logged in - If they are, segue to the MapViewController
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                self.performSegue(withIdentifier: "goToMap", sender: nil)
            }
        }
        setupTextBoxes()
        }
 
    
    //MARK: Facebook functions
    //MARK: Facebook functions
    @IBAction func loginWithFacebook(_ sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    if((FBSDKAccessToken.current()) != nil){
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                            if (error == nil){
                                //everything works print the user data
                                print(result ?? "No error")
                                
                                
                                
                                
                                
                                //********added this************
                                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                                //this is where facebook connects to firebase auth
                                Auth.auth().signIn(with: credential) { (user, error) in
                                    
                                    let ref = Database.database().reference()
                                    
                                    let fullNameArr = user?.displayName?.components(separatedBy: " ")
                                    let fn = fullNameArr?[0]
                                    let ln = fullNameArr?[1]
                                    let profilePicURL = user?.photoURL?.absoluteString
                                    
                                    ref.child("users").child(user!.uid).setValue(["firstName": fn, "lastName": ln, "photo": profilePicURL])
                                    //prints Optional("Caleb Mitcler")
                                    
                                    self.performSegue(withIdentifier: "goToMap", sender: self)
                                    if let error = error {
                                        print("Could not sign in with Facebook: \(error)")
                                        return
                                    }
                                }
                            }
                        })
                    }
                }
            }//End if error = nil
        }//End login with read permissions
    }//End loginWithFacebook
    
    //facebook delegate methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        //this is where facebook connects to firebase auth
        Auth.auth().signIn(with: credential) { (user, error) in
            self.performSegue(withIdentifier: "goToMap", sender: self)
            if let error = error {
                print("Could not sign in with Facebook: \(error)")
                return
            }
        }
    }//End login button
    
    //facebook logout
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    //Action to sign user in when sign in button is clicked
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
        // Check to make sure email and pasword text fields are not nil
        if let email = emailTextField.text, let pass = passwordTextField.text {
                spinner.startAnimating()
                // Sign in the user with Firebase
                Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                    
                    // Check that user isn't nil and assign the user to value u
                    if user != nil {
                        // User is found, go to home screen
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.wrongLoginText.isHidden = true
                        self.spinner.stopAnimating()
                        self.performSegue(withIdentifier: "goToMap", sender: self)
                    }
                    else {
                        self.spinner.stopAnimating()
                        //If there is no user that matches the credentials, display feedback here
                        self.wrongLoginText.isHidden = false
                        // Error: check error and show message
                    }
                })
        }//End if let email, pass
    }//End signInButtonTapped
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    //Function to make the boxes and buttons with rounded edges
    func setupTextBoxes(){
        let transparentBlack = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        
        //Round the corners of the text boxes and make the border white
        emailTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        signInButton.layer.cornerRadius = 10.0
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = UIColor.white.cgColor
        fbSignInButton.layer.cornerRadius = 10.0
        createAccountButton.layer.cornerRadius = 10.0
        signInButton.layer.backgroundColor = transparentBlack.cgColor
        emailTextField.delegate = self
        passwordTextField.delegate = self
        wrongLoginText.isHidden = true
    }
    
    
    //MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signInButtonTapped(UIButton())
        }
        return true
    }//End textFieldShouldReturn
    
    //Needed to go back to the login page - DO NOT REMOVE
    @IBAction func unwindToLogin(unwindSegue: UIStoryboardSegue) {}

}//End class
