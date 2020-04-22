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
    var spamMessageArray: [String] = []
    
    var random = LinearCongruentialGenerator()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        self.navigationItem.title = nameTitle
        self.messageTextView.isScrollEnabled = false
        textViewDidChange(messageTextView)
        self.sendButton.isEnabled = false
        messageTextViewDidChange()
    }
    



    @IBAction func sendButtonDidTapped(_ sender: Any) {
        guard let messageText = messageTextView.text, let receiverEmail = receiver else { return }
        sendEncryptedMail(messageText: messageText, receiver: receiverEmail)
        let vc = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func sendSpamMail(_ sender: Any) {
        self.spamMessageArray.removeAll()
        let fullText = "Whenever Maisie draws a house, it’s a square, pointy-roofed affair with four neat windows and a smoking chimney.We; brought her up in a rented terrace. So why this capitalist ideal – this detached manor with lead-lined windows and a wood burning stove? Is this what she wants? We bake our bread and visit the community orchard. We even had that talk about the sharing economy, although she was quite sleepy after toddler bounce. But still she draws people in the windows who are “not mummy and daddy.” I fear she’s putting crayon tenants in there and bleeding them dry"
        var words: [String] = []
        
        // remove all punctuations from text.
        fullText.enumerateSubstrings(in: fullText.startIndex..<fullText.endIndex, options: .byWords, {
            (substring, _, _, _) -> () in
            words.append(substring!)
            })

        for _ in 0..<20 {
            let intRandNum: Int = (Int)(random.random() * 100)
            print(intRandNum)
            self.spamMessageArray.append(words[intRandNum])
        }
        let randomMailText = spamMessageArray.joined(separator: " ")
        print(randomMailText)
        guard let receiverEmail = receiver else { return }
        sendEncryptedMail(messageText: randomMailText, receiver: receiverEmail)
    }
    
    
    
    func sendEncryptedMail(messageText: String, receiver: String) {
        if let currentUser = Auth.auth().currentUser?.email {
            let message = Message()
            message.sender = currentUser
            let encryptedMessage = messageText.aesEncrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
            message.message = encryptedMessage!
            let hashMail = messageText.sha256()
            // hash the mail and save to realm
            message.hashMessage = hashMail
            message.receiver = receiver
            message.writeToRealm()
            
        }
    }
    
}




extension SendMailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        messageTextViewDidChange()
    }
    

    func messageTextViewDidChange() {
           
        guard let message = messageTextView.text, !message.isEmpty else {
            sendButton.isEnabled = false
            sendButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            return
        }
        sendButton.isEnabled = true
        sendButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
}




