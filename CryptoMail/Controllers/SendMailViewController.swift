//
//  SendMailViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 8.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase


class SendMailViewController: UIViewController {

    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    var nameTitle: String?
    var receiver: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nameTitle
    }
    


    @IBAction func sendButtonDidTapped(_ sender: Any) {
        print(self.messageTextView.text!)
        if let currentUser = Auth.auth().currentUser?.email {
            let message = Message()
            message.sender = currentUser
            guard let messageText = messageTextView.text, let receiverEmail = receiver else { return }
            message.message = messageText
            message.receiver = receiverEmail
            message.writeToRealm()
        }

        let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    
}
