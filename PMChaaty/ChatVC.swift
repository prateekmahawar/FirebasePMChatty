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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showOrHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showOrHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    func showOrHideKeyboard(_ notification:Notification) {
        if let keyboardInfo: Dictionary = notification.userInfo {
            if notification.name == NSNotification.Name.UIKeyboardWillShow {
                UIView.animate(withDuration: 1, animations: { () in
                    self.constraintToBottom.constant = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
                    self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    
                    self.tableViewScrollToBottom(true)
                    
                }) 
            } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
                UIView.animate(withDuration: 1, animations: {  () in
                    self.constraintToBottom.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                   
                    self.tableViewScrollToBottom(true)
                    
                }) 
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @IBAction func sendBtnPressed(_ sender: AnyObject) {
        self.chatTextField.resignFirstResponder()
        if chatTextField.text != "" {
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, AnyObject>
        let messageId = message["senderId"] as! String

        
        if messageId == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageReceived, for: indexPath) as! ChatTableViewCell
            cell.configureCell(messageId,message:message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdMessageSend, for: indexPath) as! ChatTableViewCell
            cell.configureCell(messageId,message:message)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
    
    func tableViewScrollToBottom(_ animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
            
        })
    }
    
}
extension ChatVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
