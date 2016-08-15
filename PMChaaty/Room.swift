//
//  Room.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 08/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import Foundation
import UIKit

class Room {
    var caption:String!
    var thumbnail:String!
    var id:String!
    
    init(key:String, snapshot: Dictionary<String, AnyObject>) {
        self.id = key
        self.caption = snapshot["caption"] as! String
        self.thumbnail = snapshot["thumbnailUrlFromStorage"] as! String
    }
    
}