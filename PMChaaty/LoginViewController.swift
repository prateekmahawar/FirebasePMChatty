//
//  LoginViewController.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomVC.dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
        
        
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func loginBtnTapped(sender: AnyObject) {
        guard let email = emailTxtField.text where !email.isEmpty , let password = passwordTxtField.text where !password.isEmpty else {
            ProgressHUD.showError("Email/Password can't be empty")
            return
        }
        ProgressHUD.show("Signing In....")
        DataService.dataService.logIn(email, password: password)
    }

    

}
