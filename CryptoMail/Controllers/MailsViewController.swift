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
            let predicate = NSPredicate(format: "sender = %@ OR receiver = %@", "\(currentUser)", "\(currentUser)")
            messages = realm.objects(Message.self).filter(predicate)
        }
        
    }
    
}



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
        let currentUser = Auth.auth().currentUser?.email
        if messages[indexPath.row].sender == currentUser {
            cell.senderLabel.text = "You"
            
        } else {
            cell.senderLabel.text = messages[indexPath.row].sender
        }
        
        if messages[indexPath.row].receiver == currentUser {
            cell.receiverLabel.text = "You"
        } else {
            cell.receiverLabel.text = messages[indexPath.row].receiver
        }
        
        cell.messageLabel.text = messages[indexPath.row].message
        return cell
    }
    
    
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
    
    
    
    
}
