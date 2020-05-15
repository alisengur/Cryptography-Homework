//
//  SpamMailViewController.swift
//  
//
//  Created by Ali Şengür on 10.05.2020.
//

import UIKit
import RealmSwift
import FirebaseAuth

class SpamMailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var messages: Results<Message>!
    let currentUser = Auth.auth().currentUser?.email
    var concatenatedMail: [String] = []
    var key: Results<Key>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        self.reloadData()
    }
    
    fileprivate func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let cellNib = UINib(nibName: "SpamMailsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SpamMailsTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    func reloadData() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "spam = true")
        messages = realm.objects(Message.self).filter(predicate)
        key = realm.objects(Key.self)
    }
    
    
    @IBAction func navigateToSendSpam(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "UsersForSendingVievController") as? UsersForSendingVievController {
            vc.titleMode = .spamTitle
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func decrypt(messageData: String) -> String? {
        let encryptedMessage = messageData.aesDecrypt(key: key[0].key, iv: "1234567812345678")
        return encryptedMessage
    }
    
    
    @IBAction func navigateToSpamAnalysis(_ sender: Any) {
        if messages.count < 5 {
            let alert = UIAlertController(title: "Warning", message: "There must be at least five mail to pass to the analysis screen", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "SpamAnalysisViewController") as? SpamAnalysisViewController {
                vc.concatenatedText = self.sendConcatMailToSpamAnalysis()
                // use top five messages for spam analysis
                vc.mailOne = decrypt(messageData: messages[0].message!)
                vc.mailTwo = decrypt(messageData: messages[1].message!)
                vc.mailThree = decrypt(messageData: messages[2].message!)
                vc.mailFour = decrypt(messageData: messages[3].message!)
                vc.mailFive = decrypt(messageData: messages[4].message!)
                
                vc.hashOne = messages[0].hashMessage
                vc.hashTwo = messages[1].hashMessage
                vc.hashThree = messages[2].hashMessage
                vc.hashFour = messages[3].hashMessage
                vc.hashFive = messages[4].hashMessage
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
    }
    
    
    func sendConcatMailToSpamAnalysis() -> String {
        concatenatedMail.removeAll()
        for i in 0..<messages.count {
            if let decryptedMessage = decrypt(messageData: messages[i].message!) {
                self.concatenateMail(mail: decryptedMessage)
            }
        }
        let text = concatenatedMail.map { String($0) }
        .joined(separator: " ")
        return text
    }
    
    func concatenateMail(mail: String){
        let words = mail.components(separatedBy: .whitespaces)
        for word in words {
            self.concatenatedMail.append(word)
        }
    }
    
    
}

extension SpamMailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpamMailsTableViewCell", for: indexPath) as! SpamMailsTableViewCell
        cell.descriptionLabel.text = "This mail encrypted with AES256"
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.receiverLabel.text = messages[indexPath.row].receiver
        
        // decrypt message
        if messages[indexPath.row].sender == self.currentUser || messages[indexPath.row].receiver == self.currentUser {
            let decryptedMessage = decrypt(messageData: messages[indexPath.row].message!)
            cell.messageLabel.text = decryptedMessage
        } else {
            cell.messageLabel.text = messages[indexPath.row].message
        }
        
        if let decryptedMessage = decrypt(messageData: messages[indexPath.row].message!) {
            if controlIntegrityOfMessages(message: decryptedMessage, hashMail: messages[indexPath.row].hashMessage) {
                cell.cautionImage.isHidden = true
            } else {
                cell.cautionImage.isHidden = false
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "DetailMailViewController") as? DetailMailViewController {
            vc.pageMode = .spam
            vc.senderTitle = "From: '\(messages[indexPath.row].sender)'"
            vc.receiverTitle = "To: '\(messages[indexPath.row].receiver)'"
            let decryptedMessage = decrypt(messageData: messages[indexPath.row].message!)
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



    
    
    
    

