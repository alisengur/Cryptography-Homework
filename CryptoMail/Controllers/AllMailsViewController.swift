//
//  AllMailsViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 9.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth


class AllMailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var messages: Results<Message>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        self.reloadData()
    }
    
    
    fileprivate func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cellNib = UINib(nibName: "AllMailsTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "AllMailsTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    func reloadData() {
        let realm = try! Realm()
        messages = realm.objects(Message.self)
        
    }
    

}


extension AllMailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages != nil {
            return messages.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllMailsTableViewCell", for: indexPath) as! AllMailsTableViewCell
        let currentUser = Auth.auth().currentUser?.email
        if messages[indexPath.row].sender == currentUser {
            cell.senderLabel.textColor = UIColor.red
            cell.senderLabel.text = "You"
            
        } else {
            cell.senderLabel.text = messages[indexPath.row].sender
        }
        
        if messages[indexPath.row].receiver == currentUser {
            cell.receiverLabel.textColor = UIColor.red
            cell.receiverLabel.text = "You"
        } else {
            cell.receiverLabel.text = messages[indexPath.row].receiver
        }
        
        cell.messageLabel.text = messages[indexPath.row].message
        return cell
    }
    
    
    
    
}
