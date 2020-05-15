//
//  RSAMailsViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 11.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth

class RSAMailsViewController: UIViewController {

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
        let cellNib = UINib(nibName: "RSAMailsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "RSAMailsTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    func reloadData() {
        let realm = try! Realm()
        // fetch the current user messages
        let predicate = NSPredicate(format: "rsa = true")
        messages = realm.objects(Message.self).filter(predicate)
        
    }
    
    
    @IBAction func navigateToSendMail(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "UsersForSendingVievController") as? UsersForSendingVievController {
            vc.titleMode = .rsaTitle
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


extension RSAMailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RSAMailsTableViewCell", for: indexPath) as! RSAMailsTableViewCell
        cell.descriptionLabel.text = "This mail signed with RSA"
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.receiverLabel.text = messages[indexPath.row].receiver
        
        // decrypted message
        
        if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
            if let encryptedMail = messages[indexPath.row].message {
                let encrytedData = Data(base64Encoded: encryptedMail, options: [])
                AsymmetricCryptoManager.sharedInstance.decryptMailWithPrivateKey(encrytedData!) { (success, result, error) -> Void in
                    if success {  // decrypt data by sender's private key
                        cell.messageLabel.text = result!  // write decrypted data
                        print("Decrypted message : \(result!)")
                        print("Signed message : \(self.messages[indexPath.row].signedMessage!)")

                        AsymmetricCryptoManager.sharedInstance.signMessageWithPrivateKey((result?.sha256())!) { (success, data, error) -> Void in
                            if success {
                                let b64encoded = data!.base64EncodedString(options: [])  // signed message
                                if b64encoded == self.messages[indexPath.row].signedMessage {
                                    cell.signDescriptionLabel.text = "Signature verification succeed"
                                    cell.cautionImage.isHidden = true
                                } else {
                                    cell.signDescriptionLabel.text = "Signature verification failed"
                                    cell.signDescriptionLabel.textColor = UIColor.red
                                    cell.cautionImage.isHidden = false
                                }
                            } else {
                                print("Error signing message")
                            }
                        }
                    } else {
                        print("decryption error")
                    }
                }
            }
        } else {
            cell.messageLabel.text = messages[indexPath.row].message
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "DetailMailViewController") as? DetailMailViewController {
            vc.pageMode = .rsa
            vc.senderTitle = "From: '\(messages[indexPath.row].sender)'"
            vc.receiverTitle = "To: '\(messages[indexPath.row].receiver)'"
            
            if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
                if let encryptedMail = messages[indexPath.row].message {
                    let encrytedData = Data(base64Encoded: encryptedMail, options: [])
                    AsymmetricCryptoManager.sharedInstance.decryptMailWithPrivateKey(encrytedData!) { (success, result, error) -> Void in
                        if success {
                            print(result!)
                            vc.mailTextView.text = result
                        } else {
                            print("Decrypting error")
                        }
                    }
                }
            } else {
                //vc.mailText = self.messages[indexPath.row].message
                vc.mailTextView.text = self.messages[indexPath.row].message
            }
            vc.hashedMailFromDatabase = self.messages[indexPath.row].hashMessage
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

