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
    //let mailOne: String?
    
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
        
    }
    
    
    @IBAction func navigateToSendSpam(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "UsersForSendingVievController") as? UsersForSendingVievController {
            vc.titleMode = .spamTitle
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func navigateToSpamAnalysis(_ sender: Any) {
        if messages.count < 5 {
            print("Must at least 5 spam mail exist for navigate to spam analysis")
            return
        } else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let vc = mainStoryBoard.instantiateViewController(withIdentifier: "SpamAnalysisViewController") as? SpamAnalysisViewController {
                vc.concatenatedText = self.sendConcatMailToSpamAnalysis()
                vc.mailOne = messages[0].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
                vc.mailTwo = messages[1].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
                vc.mailThree = messages[2].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
                vc.mailFour = messages[3].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
                vc.mailFive = messages[4].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
                
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
            if let decryptedMessage = messages[i].message.aesDecrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678") {
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
            vc.pageMode = .spam
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



    
    
    
    

