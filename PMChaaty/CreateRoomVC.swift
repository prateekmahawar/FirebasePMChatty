//
//  CreateRoomVC.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateRoomVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var choosePhotoBtn: UIButton!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var captionLbl: UITextField!
    
    var selectedPhoto : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(CreateRoomVC.dismissKeyboard(_:)))
        dismissKeyboard.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboard)
        
    
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    @IBAction func cancelBtnTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func selectPhotoBtnTapped(sender: AnyObject) {
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagepicker.sourceType = .Camera
        } else {
            imagepicker.sourceType = .PhotoLibrary
        }
        
        self.presentViewController(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        photoImg.image = selectedPhoto
        picker.dismissViewControllerAnimated(true, completion: nil)
        choosePhotoBtn.hidden = true
    }
    @IBAction func createRoomBtnTapped(sender: AnyObject) {
        
        if photoImg.image != nil {
        var data = NSData()
        data = UIImageJPEGRepresentation(photoImg.image!, 0.1)!
        
        guard let captionText = captionLbl.text where !captionText.isEmpty else {
            ProgressHUD.showError("Username/Image can't be empty")
            return
        }
        
        DataService.dataService.CreateNewRoom((FIRAuth.auth()?.currentUser)!, caption: captionText, data: data)
        dismissViewControllerAnimated(true, completion: nil)
        } else {
            ProgressHUD.showError("Username/Image can't be empty")
        }
        }
    
}
