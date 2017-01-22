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

    func configureCell(_ idUser:String, message: Dictionary <String, AnyObject>) {
        self.messageTextLabel.text = message["message"] as! String

        DataService.dataService.PEOPLE_REF.child(idUser).observe(.value, with: { snapshot -> Void in
            let dict = snapshot.value as! Dictionary<String, AnyObject>
            if let imageUrle = dict["profileImage"]  {
              let imageUrl = imageUrle as! String
            if imageUrl.hasPrefix("gs://")  {
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("Error Downloading: \(error)")
                        return
                    }
                    self.profileImageView.image = UIImage.init(data: data!)
                })
            } else {
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                    let data = try? Data(contentsOf: URL(string: imageUrl)!)
                    
                    var image : UIImage?
                    if data != nil {
                        
                        image = UIImage(data: data!)
                    }
                    DispatchQueue.main.async {
                        
                        self.profileImageView.image = image
                        
                    }
                }
                }

            }
            })
    }
}
