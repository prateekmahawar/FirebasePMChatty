
//
//  LoginViewController.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomVC.dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
        
        //Google SignIn Delegate(GIDSignInUIDelegate, GIDSignInDelegate) Functions
        GIDSignIn.sharedInstance().clientID = "872245422297-slg7bp6liqsiqsdhfmlkuj3m3sua4oea.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
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

    //Google Sign In Functions
    @IBAction func googleLoginBtnPressed(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        ProgressHUD.show("Signing In....")
        print(user.authentication)
        DataService.dataService.loginWithGoogle(user.authentication)
        
    }

}
