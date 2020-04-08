//
//  UsersViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase


class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var users: Results<User>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        self.saveUserToRealm()
        self.reloadData()
        print(users!)
    }
    
    
    fileprivate func setTableView() {
        let tableViewCellNib = UINib(nibName: "UsersTableViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "UsersTableViewCell")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
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
                    user.writeToRealm()
                }
            }
        })
        
    }
    
    
    

    @IBAction func settingsButtonDidTapped(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(identifier: "SettingsTableViewController") as? SettingsTableViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}


extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil {
            return users!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell", for: indexPath) as! UsersTableViewCell
        cell.delegate = self
        cell.index = indexPath
        cell.usernameLabel?.text = users![indexPath.row].username
        cell.emailLabel?.text = users![indexPath.row].email
        
        return cell
    }
    
    
}




extension UsersViewController: UsersTableViewCellDelegate {
    func didTappedWriteMessageButton(index: Int) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "SendMailViewController") as? SendMailViewController {
            vc.nameTitle = users[index].username
            vc.receiver = users[index].email
            self.navigationController?.pushViewController(vc, animated: true)
        }
        print("tapped")
    }
    
}
