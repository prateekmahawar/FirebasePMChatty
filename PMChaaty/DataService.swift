//
//  DataService.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 07/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn

let roofRef = FIRDatabase.database().reference()

class DataService {
    
    static let dataService = DataService()
    
    fileprivate var _BASE_REF = roofRef
    fileprivate var _ROOM_REF = roofRef.child("rooms")
    fileprivate var _MESSAGE_REF = roofRef.child("messages")
    fileprivate var _PEOPLE_REF = roofRef.child("people")
    
    var currentUser : FIRUser? {
        return FIRAuth.auth()!.currentUser!
    }
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    var ROOM_REF: FIRDatabaseReference {
        return _ROOM_REF
    }
    var PEOPLE_REF: FIRDatabaseReference {
        return _PEOPLE_REF
    }
    var MESSAGE_REF: FIRDatabaseReference {
        return _MESSAGE_REF
    }
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var fileUrl:String!
    
    func CreateNewRoom(_ user:FIRUser, caption: String, data : Data) {
        let filePath = "\(user.uid)/\(Int(Date.timeIntervalSinceReferenceDate))"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).put(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error Uploading: \(error)")
                return
            }
            
            //Create a url for data(ThumbNail Image)
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            if let user = FIRAuth.auth()?.currentUser {
                let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                idRoom.setValue(["caption": caption , "thumbnailUrlFromStorage" : self.storageRef.child(metadata!.path!).description, "fileUrl": self.fileUrl ])
                
            }
            
        }
        
    }
    
    func fetchDataFromServer(_ callback: @escaping (Room) -> ()) {
        DataService.dataService.ROOM_REF.observe(.childAdded, with:  { (snapshot) in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            callback(room)
        })
    }
    
    
    //Sign Up
    func SignUp(_ username:String, email:String, password:String, data:Data) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error)
                    return
                }
            })
            let filePath = "profileImage/\(user!.uid)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).put(data, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.fileUrl = metadata?.downloadURLs![0].absoluteString
                let changeRequestPhoto = user!.profileChangeRequest()
                changeRequestPhoto.photoURL = URL(string: self.fileUrl)
                changeRequestPhoto.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else {
                        print("Profile Updated")
                    }
                })
                self.PEOPLE_REF.child((user?.uid)!).setValue(["username" : username, "email": email , "profileImage" : self.storageRef.child((metadata?.path)!).description])
                
                ProgressHUD.showSuccess("Succeeded.")
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            })
            
          })
    }
    
    //Login Func
    func logIn(_ email:String , password: String) {
     FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        ProgressHUD.showSuccess("Succedded")
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.login()
        
     })
    }
    
    //Logout Func
    func logout() {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            
            GIDSignIn.sharedInstance().disconnect()
            try firebaseAuth?.signOut()
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC")
            UIApplication.shared.keyWindow?.rootViewController = logInVC
        } catch let signOutError as NSError {
            print("Error Signing Out : \(signOutError)")
        }
    }
    
    //Update Profile
    func SaveProfile(_ username:String, email: String, data:Data) {
        let user = FIRAuth.auth()?.currentUser!
        let filePath = "profileImage/\(user!.uid)"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        self.storageRef.child(filePath).put(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Error uplaoding: \(error.localizedDescription)")
                return
            }
            self.fileUrl = metadata!.downloadURLs![0].absoluteString
            let changeRequestProfile = user!.profileChangeRequest()
            changeRequestProfile.photoURL = URL(string: self.fileUrl)
            changeRequestProfile.displayName = username
            changeRequestProfile.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    ProgressHUD.showError("Network Error")
                } else {
                    
                }
            })
            if let user = user {
                user.updateEmail(email, completion: { (error) in
                    if let error = error {
                        print("Error updating email address : \(error.localizedDescription)")
                    } else {
                        print("Email Update")
                        
                    }
                })
                
            }
            ProgressHUD.showSuccess("Saved")
        }
        
    }
    
    func CreateNewMessage(_ userId:String, roomId: String, textMessage: String) {
        let idMessage = roofRef.child("messages").childByAutoId()
        DataService.dataService.MESSAGE_REF.child(idMessage.key).setValue(["message" : textMessage, "senderId" : userId])
        DataService.dataService.ROOM_REF.child(roomId).child("messages").child(idMessage.key).setValue(true)
        
        
    }
    
    func fetchMessageFromServer(_ roomId:String, callback : @escaping (FIRDataSnapshot) -> ()) {
        DataService.dataService.ROOM_REF.child(roomId).child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            
        DataService.dataService.MESSAGE_REF.child(snapshot.key).observe(.value, with: {
            snap -> Void in
            callback(snap)
            })
        })
    }
    //Google Sign-In
//    func loginWithGoogle(_ authrntication: GIDAuthentication) {
//        
//        let credential = FIRGoogleAuthProvider.credential(withIDToken: authrntication.idToken, accessToken: authrntication.accessToken)
//        FIRAuth.auth()?.signIn(with: credential, completion: { (user:FIRUser?, error:NSError?) in
//            if error != nil {
//                print(error?.localizedDescription)
//                return
//            }  else {
//                let email = user?.email
//                let username = user?.displayName
//                let imageUrle = user?.photoURL
//                let imageUrl = String(imageUrle!)
//                
//                self.PEOPLE_REF.child((user?.uid)!).updateChildValues(["username" : username!, "email": email! , "profileImage" : imageUrl])
//                
//                ProgressHUD.showSuccess("Succedded")
//                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.login()
//            }
//        })
//        
//    }
    
}
