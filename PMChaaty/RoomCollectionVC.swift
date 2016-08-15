//
//  RoomCollectionVC.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class RoomCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var rooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        DataService.dataService.fetchDataFromServer { (room) in
//            self.rooms.append(room)
//            let indexPath = NSIndexPath(forItem: self.rooms.count - 1, inSection: 0)
//            self.collectionView?.insertItemsAtIndexPaths([indexPath])
//        }
        DataService.dataService.ROOM_REF.observeEventType(.ChildAdded, withBlock:
            { (snapshot) -> Void in
                let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
                self.rooms.append(room)
                let indexPath = NSIndexPath(forItem: self.rooms.count - 1, inSection: 0)
                self.collectionView?.insertItemsAtIndexPaths([indexPath])
                
        })
    
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return rooms.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("roomCell", forIndexPath: indexPath) as! RoomCollectionViewCell
    
        // Configure the cell
        let room = rooms[indexPath.item]
        cell.configureCell(room)
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width / 2 - 5, view.frame.size.width / 2 - 5)
    }
    
    @IBAction func logout(sender: AnyObject) {
        let actionSheetController = UIAlertController(title: "Please Select", message: "Option to select", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            print("Cancel Pressed")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let profileActionButton = UIAlertAction(title: "Profile", style: UIAlertActionStyle.Default) { (action) in
            let profileVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfile") as! ProfileTableVC
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        actionSheetController.addAction(profileActionButton)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default) { (action) in
            print("LogOut Pressed")
            self.logoutDidTapped()
        }
        actionSheetController.addAction(logoutAction)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func logoutDidTapped(){
        DataService.dataService.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChatSegue" {
            let cell = sender as! RoomCollectionViewCell
            let indexPath = collectionView?.indexPathForCell(cell)
            let room = rooms[indexPath!.row]
            let chatViewController = segue.destinationViewController as! ChatVC
            chatViewController.roomId = room.id
            
        }
    }

}
