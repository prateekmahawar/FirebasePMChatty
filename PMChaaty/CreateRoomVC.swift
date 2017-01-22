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
    
    func dismissKeyboard(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    
    @IBAction func cancelBtnTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectPhotoBtnTapped(_ sender: AnyObject) {
        let imagepicker = UIImagePickerController()
        imagepicker.delegate = self
        imagepicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagepicker.sourceType = .camera
        } else {
            imagepicker.sourceType = .photoLibrary
        }
        
        self.present(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        photoImg.image = selectedPhoto
        picker.dismiss(animated: true, completion: nil)
        choosePhotoBtn.isHidden = true
    }
    @IBAction func createRoomBtnTapped(_ sender: AnyObject) {
        
        if photoImg.image != nil {
        var data = Data()
        data = UIImageJPEGRepresentation(photoImg.image!, 0.1)!
        
        guard let captionText = captionLbl.text, !captionText.isEmpty else {
            ProgressHUD.showError("Username/Image can't be empty")
            return
        }
        
        DataService.dataService.CreateNewRoom((FIRAuth.auth()?.currentUser)!, caption: captionText, data: data)
        dismiss(animated: true, completion: nil)
        } else {
            ProgressHUD.showError("Username/Image can't be empty")
        }
        }
    
}
