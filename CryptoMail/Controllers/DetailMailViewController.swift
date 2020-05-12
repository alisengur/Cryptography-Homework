//
//  DetailMailViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 22.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit

enum DetailVCMode {
    case aes
    case rsa
    case spam
}


class DetailMailViewController: UIViewController {
    @IBOutlet weak var senderTitleLabel: UILabel!
    @IBOutlet weak var receiverTitleLabel: UILabel!
    @IBOutlet weak var mailTextView: UITextView!
    @IBOutlet weak var mailDescriptionLabel: UILabel!
    @IBOutlet weak var hashMailFromDatabase: UITextView!
    @IBOutlet weak var hashMail: UITextView!
    @IBOutlet weak var generateHashButton: UIButton!
    
    var pageMode: DetailVCMode = .aes
    var senderTitle: String?
    var receiverTitle: String?
    var mailText: String?
    var mailDescription: String?
    var mailDescLabelBackgroundColor: UIColor?
    var hashedMailFromDatabase: String?
    var hashedMail: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTextView.delegate = self
        hashMailFromDatabase.delegate = self
        hashMail.delegate = self
        self.mailDescriptionLabel.layer.cornerRadius = 5
        self.generateHashButton.layer.cornerRadius = 5
        self.mailDescriptionLabel.layer.cornerRadius = 8
        senderTitleLabel.text = self.senderTitle
        receiverTitleLabel.text = self.receiverTitle
        mailTextView.text = self.mailText
//        mailDescriptionLabel.text = self.mailDescription
//        mailDescriptionLabel.backgroundColor = mailDescLabelBackgroundColor
        hashMailFromDatabase.text = hashedMailFromDatabase
        hashMail.text = hashedMail
        self.mailTextView.isScrollEnabled = false
        textViewDidChange(mailTextView)
        self.hashMailFromDatabase.isScrollEnabled = false
        textViewDidChange(hashMailFromDatabase)
        self.hashMail.isScrollEnabled = false
        //textViewDidChange(hashMail)
        self.mailDescriptionLabel.isHidden = true
    }
    
    @IBAction func generateHashOfMail(_ sender: Any) {
        if self.pageMode == .aes || self.pageMode == .spam {
            let mail = self.mailText
            let encryptedMail = mail?.aesEncrypt(key: "pw01pw23pw45pw67", iv: "1234567812345678")
            let hashedMail = encryptedMail?.sha256()
            self.hashMail.text = hashedMail
        } else {
            if let mail = self.mailText {
                let hashedMail = mail.sha256()
                self.hashMail.text = hashedMail
            }
        }
        
        
        if verifyMail(hashMail: hashMail.text, hashMailFromDatabase: hashMailFromDatabase.text) {
            self.mailDescriptionLabel.text = "This mail verified"
            self.mailDescriptionLabel.backgroundColor = UIColor(red: 125/255, green: 200/255, blue: 134/255, alpha: 1.0)
            self.mailDescriptionLabel.isHidden = false
        } else {
            self.mailDescriptionLabel.text = "This mail have been altered or corrupted or signed by a unkown person"
            self.mailDescriptionLabel.backgroundColor = UIColor(red: 255/255, green: 121/255, blue: 121/255, alpha: 1.0)
            self.mailDescriptionLabel.isHidden = false
        }
    }
    
    
    func verifyMail(hashMail: String, hashMailFromDatabase: String) -> Bool {
        return hashMail == hashMailFromDatabase ? true : false
    }
}

extension DetailMailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
}
