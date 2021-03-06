//
//  ProfileTableVC.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import GoogleSignIn

class ProfileTableVC: UITableViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileTableVC.selectPhoto(_:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        
       
        if let user = DataService.dataService.currentUser {
            username.text = user.displayName
            email.text = user.email
            if user.photoURL != nil {
                if let data = try? Data(contentsOf: user.photoURL!) {
                    self.profileImage.image = UIImage.init(data: data)
                }
            }
        } else {
            //No user is signed in
        }
        
    }

    
    func selectPhoto(_ tap:UITapGestureRecognizer) {
        
        if GIDSignIn.sharedInstance().currentUser == nil {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        self.present(imagePicker, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("Edit not allowed")
        }
    }
    //Imagepicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveBtnPressed(_ sender: AnyObject) {
        var data = Data()
        data = UIImageJPEGRepresentation(profileImage.image!, 0.1)!
        ProgressHUD.show("Please Wait...", interaction: false)
        DataService.dataService.SaveProfile(username.text!, email: email.text!, data: data)
        
    }
 
}
