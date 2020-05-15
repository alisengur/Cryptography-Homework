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
    var key: Results<Key>!
    
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
        key = realm.objects(Key.self)
    }
    
    
    @IBAction func navigateToSendMail(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "UsersForSendingVievController") as? UsersForSendingVievController {
            vc.titleMode = .aesTitle
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func decrypt(messageData: String) -> String? {
        let encryptedMessage = messageData.aesDecrypt(key: key[0].key, iv: "1234567812345678")
        return encryptedMessage
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
        
        
        if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
            // if message is not nil, this message is not image
            if messages[indexPath.row].message != nil {
                if let message = messages[indexPath.row].message {
                    if let decryptedMessage = decrypt(messageData: message) {
                        cell.messageLabel.text = decryptedMessage /// add decrypted message to message label
                        if controlIntegrityOfMessages(message: decryptedMessage, hashMail: messages[indexPath.row].hashMessage) {
                            cell.cautionImage.isHidden = true
                        } else {
                            cell.cautionImage.isHidden = false ///  if digest of the messages are not matched, caution image bacome a visible
                        }
                    }
                }
                
            } else { // if message is nil, so this message is an image
                cell.cautionImage.isHidden = true
                cell.messageLabel.text = "📷 Photo"
            }
        } else { // if logged in with a different user (not sender and receiver)
            cell.cautionImage.isHidden = true
            if messages[indexPath.row].message != nil {
                cell.messageLabel.text = messages[indexPath.row].message
            } else {
                cell.messageLabel.text = "📷 Photo"
            }
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if messages[indexPath.row].message != nil {
            if let vc = mainStoryboard.instantiateViewController(identifier: "DetailMailViewController") as? DetailMailViewController {
                vc.pageMode = .aes
                vc.senderTitle = "From: '\(messages[indexPath.row].sender)'"
                vc.receiverTitle = "To: '\(messages[indexPath.row].receiver)'"
                
                if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
                    if let message = messages[indexPath.row].message {
                       let decryptedMessage = decrypt(messageData: message)
                        vc.mailText = decryptedMessage
                    }
                } else {
                    if let message = messages[indexPath.row].message {
                        vc.mailText = message
                    }
                }
                vc.hashedMailFromDatabase = messages[indexPath.row].hashMessage
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = mainStoryboard.instantiateViewController(identifier: "DetailWatermarkViewController") as? DetailWatermarkViewController {
                if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
                    if let watermarkMessage = decrypt(messageData: messages[indexPath.row].watermark!) {
                        print("watermark message : \(watermarkMessage)")
                        vc.imageData = messages[indexPath.row].watermarkImageData
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    vc.imageData = messages[indexPath.row].imageData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
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
