//
//  UsersForSendingVievController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 11.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase


enum TitleMode {
    case aesTitle
    case rsaTitle
    case spamTitle
}

enum WaterMarkCorner
{
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

class UsersForSendingVievController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users: Results<User>!
    var titleMode: TitleMode = .aesTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        self.reloadData()
    }
    
    fileprivate func setTableView() {
        if titleMode == .aesTitle {
            self.navigationItem.title = "Send AES Mail"
        } else if titleMode == .rsaTitle {
            self.navigationItem.title = "Send RSA Mail"
        } else {
            self.navigationItem.title = "Send Spam Mail"
        }
        
        let tableViewCellNib = UINib(nibName: "UsersForSendingTableViewCell", bundle: nil)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "UsersForSendingTableViewCell")
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


extension UsersForSendingVievController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users != nil {
            return users!.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersForSendingTableViewCell", for: indexPath) as! UsersForSendingTableViewCell
        cell.delegate = self
        cell.index = indexPath
        cell.usernameLabel?.text = users![indexPath.row].username
        cell.emailLabel?.text = users![indexPath.row].email
        if navigationItem.title == "Send AES Mail" {
            cell.sendImageButton.isHidden = false
        } else if navigationItem.title == "Send RSA Mail" {
            cell.sendImageButton.isHidden = true
        } else {
            cell.sendImageButton.isHidden = true
        }
        return cell
    }
}




extension UsersForSendingVievController: UsersForSendingTableViewCellDelegate {
    func sendImageButtonDidTapped(index: Int) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "SendWatermarkViewController") as? SendWatermarkViewController {
//            let imageData = UIImage(named: "monalisa")
//            let pngData = imageData?.pngData()!
//            let image = UIImage(data: pngData!)
//            vc.image = image
            vc.nameTitle = users[index].username
            vc.receiver = users[index].email
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTappedWriteMessageButton(index: Int) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "SendMailViewController") as? SendMailViewController {
        vc.nameTitle = users[index].username
        vc.receiver = users[index].email
        
        if navigationItem.title == "Send AES Mail" {
            vc.pageMode = .aesMail
        } else if navigationItem.title == "Send RSA Mail" {
            vc.pageMode = .rsaMail
        } else {
            vc.pageMode = .spamMail
        }
            
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    


}

