
//
//  LoginViewController.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomVC.dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
//        
//        //Google SignIn Delegate(GIDSignInUIDelegate, GIDSignInDelegate) Functions
//        GIDSignIn.sharedInstance().clientID = "872245422297-slg7bp6liqsiqsdhfmlkuj3m3sua4oea.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func loginBtnTapped(_ sender: AnyObject) {
        guard let email = emailTxtField.text, !email.isEmpty , let password = passwordTxtField.text, !password.isEmpty else {
            ProgressHUD.showError("Email/Password can't be empty")
            return
        }
        ProgressHUD.show("Signing In....")
        DataService.dataService.logIn(email, password: password)
    }

    //Google Sign In Functions
//    @IBAction func googleLoginBtnPressed(_ sender: AnyObject) {
//        GIDSignIn.sharedInstance().signIn()
//        
//    }
//    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: NSError!) {
//        
//        if user != nil {
//        print(user.authentication)
//        ProgressHUD.show("Signing In....")
//        DataService.dataService.loginWithGoogle(user.authentication)
//        }
        
    }
    
 


