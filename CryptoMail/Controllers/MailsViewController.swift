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
        let realm = try! Realm()
        // fetch the current user messages
        let predicate = NSPredicate(format: "aes = true")
        messages = realm.objects(Message.self).filter(predicate)
        
    }
    
    
    @IBAction func navigateToSendMail(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "UsersForSendingVievController") as? UsersForSendingVievController {
            vc.titleMode = .aesTitle
            self.navigationController?.pushViewController(vc, animated: true)
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
        cell.descriptionLabel.text = "This mail encrypted with AES256"
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.receiverLabel.text = messages[indexPath.row].receiver
        
        // decrypted message
        if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
            let decryptedMessage = messages[indexPath.row].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
            cell.messageLabel.text = decryptedMessage
        } else {
            cell.messageLabel.text = messages[indexPath.row].message
        }
        
        
        if controlIntegrityOfMessages(message: messages[indexPath.row].message, hashMail: messages[indexPath.row].hashMessage) {
            cell.cautionImage.isHidden = true
        } else {
            cell.cautionImage.isHidden = false
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "DetailMailViewController") as? DetailMailViewController {
            vc.pageMode = .aes
            vc.senderTitle = "From: '\(messages[indexPath.row].sender)'"
            vc.receiverTitle = "To: '\(messages[indexPath.row].receiver)'"
            let decryptedMessage = messages[indexPath.row].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
            vc.mailText = decryptedMessage
            vc.hashedMailFromDatabase = messages[indexPath.row].hashMessage
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
