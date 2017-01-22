//
//  RoomCollectionViewCell.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 08/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import Firebase

class RoomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailPhoto: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    
    func configureCell(_ room: Room){
        self.captionLbl.text = room.caption
        if let imageUrl = room.thumbnail {
            if imageUrl.hasPrefix("gs://") {
                FIRStorage.storage().reference(forURL: imageUrl).data(withMaxSize: INT64_MAX, completion: { (data, error) in
                    if let error = error {
                        print("Error Downloading : \(error)")
                        return
                    }
                    self.thumbnailPhoto.image = UIImage.init(data: data!)
                })
            } else if let url = URL(string:imageUrl) , let data = try? Data(contentsOf: url) {
                self.thumbnailPhoto.image = UIImage.init(data: data)
            }
            
        }
        
    }
}
