//
//  ChatTableViewCell.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 09/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
    }

    func configureCell(idUser:String, message: Dictionary <String, AnyObject>) {
        self.messageTextLabel.text = message["message"] as! String

        DataService.dataService.PEOPLE_REF.child(idUser).observeEventType(.Value, withBlock: { snapshot -> Void in
            let dict = snapshot.value as! Dictionary<String, AnyObject>
            if let imageUrle = dict["profileImage"]  {
              let imageUrl = imageUrle as! String
            if imageUrl.hasPrefix("gs://")  {
                FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("Error Downloading: \(error)")
                        return
                    }
                    self.profileImageView.image = UIImage.init(data: data!)
                })
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let data = NSData(contentsOfURL: NSURL(string: imageUrl)!)
                    
                    var image : UIImage?
                    if data != nil {
                        
                        image = UIImage(data: data!)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.profileImageView.image = image
                        
                    }
                }
                }

            }
            })
    }
}
