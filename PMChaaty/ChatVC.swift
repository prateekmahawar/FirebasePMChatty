//
//  ChatVC.swift
//  PMChaaty
//
//  Created by Prateek Mahawar on 06/08/16.
//  Copyright © 2016 Prateek Mahawar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift

private struct Constants {
    static let cellIdMessageReceived = "MessageCellYou"
    static let cellIdMessageSend = "MessageCellMe"
}

class ChatVC: UIViewController {
    
    var roomId:String!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [FIRDataSnapshot] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().enable = false
        tableView.delegate =  self
        tableView.dataSource = self
        
        DataService.dataService.fetchMessageFromServer(roomId) { (snap) in
            self.messages.append(snap)
            print(self.messages)
            self.tableView.reloadData()
            self.tableViewScrollToBottom(true)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatVC.showOrHideKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatVC.showOrHideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    func showOrHideKeyboard(notification:NSNotification) {
        if let keyboardInfo: Dictionary = notification.userInfo {
            if notification.name == UIKeyboardWillShowNotification {
                UIView.animateWithDuration(1, animations: { () in
                    self.constraintToBottom.constant = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                    
                    self.tableViewScrollToBottom(true)
                    
                }
            } else if notification.name == UIKeyboardWillHideNotification {
                UIView.animateWithDuration(1, animations: {  () in
                    self.constraintToBottom.constant = 0
                    self.view.layoutIfNeeded()
                }) { (completed: Bool) -> Void in
                   
                    self.tableViewScrollToBottom(true)
                    
                }
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func sendBtnPressed(sender: AnyObject) {
        self.chatTextField.resignFirstResponder()
        if chatTextField != "" {
            if let user = FIRAuth.auth()?.currentUser {
                DataService.dataService.CreateNewMessage(user.uid, roomId: roomId, textMessage: chatTextField.text!)
                self.tableViewScrollToBottom(true)
                
            } else {
              //No user Signed in
            }
            
            self.chatTextField.text = nil
        } else {
            print("Empty String")
        }
        
    }

}

extension ChatVC: UITableViewDelegate , UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        let messageId = message["senderId"] as! String

        
        if messageId == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellIdMessageReceived, forIndexPath: indexPath) as! ChatTableViewCell
            cell.configureCell(messageId,message:message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellIdMessageSend, forIndexPath: indexPath) as! ChatTableViewCell
            cell.configureCell(messageId,message:message)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        
        let messageCount = message["message"] as! String
        let nolines = Int((messageCount.characters.count / 20)) + 1
        if nolines > 1 {
            return 35.0 * CGFloat(nolines)
        }
        else {
            return 45.0
        }
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
}
extension ChatVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}