//
//  ResetPasswordViewController.swift
//  pickUpAndPlay
//
//  Created by Dakota Cowell on 8/19/17.
//  Copyright © 2017 Caleb Mitcler. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var submitButtonTextField: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        if emailTextField.text != "" {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
                // ...
            }
        }
    }
    
    private func setupButtons() {
        submitButtonTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
    }
}
