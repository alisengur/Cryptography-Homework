//
//  MailsViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth


class MailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    

    var messages: Results<Message>!
    let currentUser = Auth.auth().currentUser?.email
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        self.reloadData()
    }
    

    fileprivate func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: "MailsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "MailsTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    func reloadData() {
        if let currentUser = Auth.auth().currentUser?.email {
            let realm = try! Realm()
            // fetch the current user messages
            let predicate = NSPredicate(format: "sender = %@ OR receiver = %@", "\(currentUser)", "\(currentUser)")
            messages = realm.objects(Message.self).filter(predicate)
        }
        
    }
    
}




//MARK: -TableView functions
extension MailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages.count
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailsTableViewCell", for: indexPath) as! MailsTableViewCell
         // current user's email from firebase
        if messages[indexPath.row].sender == currentUser {  /// if sender is current user
            cell.senderLabel.text = "You"
            
        } else {
            cell.senderLabel.text = messages[indexPath.row].sender
        }
        
        if messages[indexPath.row].receiver == currentUser {  /// if receiver is current user
            cell.receiverLabel.text = "You"
        } else {
            cell.receiverLabel.text = messages[indexPath.row].receiver
        }
        
        // decrypted message
        let decryptedMessage = messages[indexPath.row].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
        cell.messageLabel.text = decryptedMessage
        
        if controlIntegrityOfMessages(message: decryptedMessage!, hashMail: messages[indexPath.row].hashMessage) {
            cell.cautionImage.isHidden = true
        } else {
            cell.cautionImage.isHidden = false
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "DetailMailViewController") as? DetailMailViewController {
            if messages[indexPath.row].sender == currentUser {
                vc.mailTitle = "From 'You' to '\(messages[indexPath.row].receiver)'"
            }
            if messages[indexPath.row].receiver == currentUser {
                vc.mailTitle = "From '\(messages[indexPath.row].sender)' to 'You'"
            }
            let decryptedMessage = messages[indexPath.row].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
            vc.mailText = decryptedMessage
            
            // Check if the mail has changed
            if controlIntegrityOfMessages(message: decryptedMessage!, hashMail: messages[indexPath.row].hashMessage) {
                vc.mailDescription = "This email is completely secure"
                vc.mailDescriptionLabel.backgroundColor = UIColor(red: 125/255, green: 200/255, blue: 134/255, alpha: 1.0)
            } else {
                vc.mailDescription = "This email may have been changed"
                vc.mailDescriptionLabel.backgroundColor = UIColor(red: 255/255, green: 121/255, blue: 121/255, alpha: 1.0)
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    // swipe to delete from table view and realm database
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let message = messages?[indexPath.row] {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(message)
                    }
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                }
            }
        }
    
    

    
    
    //MARK: -This function checks that the mail and hashed mail are same.
    func controlIntegrityOfMessages(message: String, hashMail: String) -> Bool {
        let hashedMessage = message.sha256()
        if hashedMessage == hashMail {
            return true
        } else {
            return false
        }
    }
}
