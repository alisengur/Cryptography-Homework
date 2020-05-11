//
//  SendSpamMailViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 10.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase

class SendSpamMailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users: Results<User>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        self.reloadData()
    }
    
    fileprivate func setTableView() {
        self.navigationItem.title = "Users"
        let tableViewCellNib = UINib(nibName: "SendSpamTableViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "SendSpamTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // fetch the username of users in order
    func reloadData() {
        let realm = try! Realm()
        users = realm.objects(User.self).sorted(byKeyPath: "username", ascending: true)
        self.tableView.reloadData()
    }
    
    
    func saveUserToRealm(){
        let dbRef = Database.database().reference()
        dbRef.child("users").observe(.value, with: {
            snapshot in
            
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                let username = (snap.value as! NSDictionary)["username"] as? String
                let email = (snap.value as! NSDictionary)["email"] as? String
                
                let user = User()
                if let username = username, let email = email {
                    user.username = username
                    user.email = email
                    user.writeToRealm() // save users to realm database
                }
            }
        })
    }
}


extension SendSpamMailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil {
            return users!.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendSpamTableViewCell", for: indexPath) as! SendSpamTableViewCell
        cell.delegate = self
        cell.index = indexPath
        cell.usernameLabel?.text = users![indexPath.row].username
        cell.emailLabel?.text = users![indexPath.row].email
        
        return cell
    }
    
    

    
}



extension SendSpamMailViewController: SendSpamTableViewCellDelegate {
    func didTappedWriteMessageButton(index: Int) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "SendMailViewController") as? SendMailViewController {
        vc.nameTitle = users[index].username
        vc.receiver = users[index].email
        self.navigationController?.pushViewController(vc, animated: true)

        }
    }
}
    
    
    
    
