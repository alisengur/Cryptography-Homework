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


enum SendMailVCMode {
    case aesMail
    case rsaMail
    case spamMail
}



class SendMailViewController: UIViewController {

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var keyPairLabel: UILabel!
    @IBOutlet weak var keyPairButton: UIButton!
    @IBOutlet weak var sendAESButton: UIButton!
    @IBOutlet weak var sendRSAButton: UIButton!
    @IBOutlet weak var generateSpamButton: UIButton!
    @IBOutlet weak var corruptSwitch: UISwitch!
    @IBOutlet weak var sendSpamButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    var pageMode: SendMailVCMode = .aesMail
    var nameTitle: String?
    var receiver: String?
    var switchState: Bool?
    var spamMessageArray: [String] = []
    var random = LinearCongruentialGenerator()
    var image: UIImage?
    var key: Results<Key>!
    //var tempRSAEncrypted: String?
    
    
    var keyPairExists = AsymmetricCryptoManager.sharedInstance.keyPairExists() {
        didSet {
            if keyPairExists {
                keyPairLabel.text = "A valid keypair is present"
                keyPairButton.setTitle("Delete keypair", for: UIControl.State())
            } else {
                keyPairLabel.text = "No key pair present"
                keyPairButton.setTitle("Generate keypair", for: UIControl.State())
            }
        }
    }
    
    
        

    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        self.navigationItem.title = nameTitle
        self.messageTextView.isScrollEnabled = false
        textViewDidChange(messageTextView)
        self.setPageMode()
        self.sendAESButton.isEnabled = false
        //messageTextViewDidChange()
        corruptSwitch.setOn(false, animated: true)
        self.switchState = false
        self.sendSpamButton.isEnabled = false
        self.imageView.image = image
        
        // fetch key object
        let realm = try! Realm()
        key = realm.objects(Key.self)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyPairExists = AsymmetricCryptoManager.sharedInstance.keyPairExists()
    }
    
    
    
    fileprivate func setPageMode() {
        if self.pageMode == .aesMail {
            messageTextView.text = "Write something.."
            messageTextView.textColor = UIColor.lightGray
            messageTextView.selectedTextRange = messageTextView.textRange(from: messageTextView.beginningOfDocument, to: messageTextView.beginningOfDocument)
            self.keyPairButton.isEnabled = false
            self.generateSpamButton.isEnabled = false
            self.sendRSAButton.isEnabled = false
            self.sendSpamButton.isEnabled = false
        } else if self.pageMode == .rsaMail {
            messageTextView.text = "Write something.."
            messageTextView.textColor = UIColor.lightGray
            messageTextView.selectedTextRange = messageTextView.textRange(from: messageTextView.beginningOfDocument, to: messageTextView.beginningOfDocument)
            self.generateSpamButton.isEnabled = false
            self.sendAESButton.isEnabled = false
            self.sendSpamButton.isEnabled = false
        } else {
            self.keyPairButton.isEnabled = false
            self.sendAESButton.isEnabled = false
            self.sendRSAButton.isEnabled = false
        }
    }
    
    
    
    @IBAction func generateKeypair(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        if keyPairExists { // delete current key pair
            AsymmetricCryptoManager.sharedInstance.deleteSecureKeyPair({ (success) -> Void in
                if success {
                    print("Keypair successfully deleted")
                    self.keyPairExists = false
                } else {
                    print("Error deleting keypair.") }
                self.view.isUserInteractionEnabled = true
            })
        } else {  // generate keypair
            AsymmetricCryptoManager.sharedInstance.createSecureKeyPair({ (success, error) -> Void in
               if success {
                   print("RSA-2048 keypair successfully generated.")
                   self.keyPairExists = true
               } else {
                print("An error happened while generating a keypair") }
               self.view.isUserInteractionEnabled = true
           })
        }
    }
    
    
    
    
    @IBAction func generateSpamMail(_ sender: Any) {
        self.spamMessageArray.removeAll()
        let fullText = "Whenever Maisie draws a house, it’s a square, pointy-roofed affair with four neat windows and a smoking chimney.We; brought her up in a rented terrace. So why this capitalist ideal – this detached manor with lead-lined windows and a wood burning stove? Is this what she wants? We bake our bread and visit the community orchard. We even had that talk about the sharing economy, although she was quite sleepy after toddler bounce. But still she draws people in the windows who are “not mummy and daddy.” I fear she’s putting crayon tenants in there and bleeding them dry"
        var words: [String] = []
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
        self.messageTextView.text = randomMailText
        self.sendSpamButton.isEnabled = true
    }
    
    
    
    
    @IBAction func corruptSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.switchState = true
        } else {
            self.switchState = false
        }
    }
    
    
    
    
    @IBAction func sendAESButtonDidTapped(_ sender: Any) {
        guard let messageText = messageTextView.text, let receiverEmail = receiver else { return }
        print("Message text: \(messageText)")
        if let currentUser = Auth.auth().currentUser?.email {
            let message = Message()
            message.sender = currentUser
            message.receiver = receiverEmail
            
            
            if switchState == false {  // If switch is not selected
                message.message = encrypt(messageData: messageText)! /// save encrypted message to realm
                message.aes = true
                let hashMail = messageText.sha256()  /// hash encrypted message and save to realm
                message.hashMessage = hashMail
                message.writeToRealm()
            } else {  // If switch is selected
                let newMessage = messageText
                let corruptedMessage = String(newMessage.dropLast()) /// Corrupt the message(remove the last character for test scenario)
                message.message = encrypt(messageData: corruptedMessage)!
                message.aes = true
                let hashMail = encrypt(messageData: messageText)!.sha256()
                // hash the mail and save to realm
                message.hashMessage = hashMail
                message.writeToRealm()
            }
        }
        if let navigation = self.navigationController {
            navigation.popToRootViewController(animated: true)
        }
    }
    
    func encrypt(messageData: String) -> String? {
        let encryptedMessage = messageData.aesEncrypt(key: key[0].key, iv: "1234567812345678")
        return encryptedMessage
    }
    
    
    
    
    @IBAction func sendRSAButtonDidTapped(_ sender: Any) {
        guard let messageText = messageTextView.text, let receiverEmail = receiver else { return }
        if let currentUser = Auth.auth().currentUser?.email {
            let message = Message()
            message.sender = currentUser  // save sender
            message.receiver = receiverEmail  // save receiver
            message.hashMessage = messageText.sha256()
            print("Hashed form of mail : \(messageText.sha256())")
            
            if switchState == false {  // Not active the Man in the Middle
                // Encrypting
                AsymmetricCryptoManager.sharedInstance.encryptMailWithPublicKey(mail: messageText) { (success, data, error) -> Void in
                    if success {
                        let b64encoded = data!.base64EncodedString(options: [])
                        print("Encrypted Mail : \(b64encoded)")
                        message.message = b64encoded  // save encrypted message
                        //message.hashMessage = b64encoded.sha256() // save digest of encrypted mail
                        message.rsa = true  // save state of rsa
                    } else {
                        print("Encrypting error")
                    }
                }
                
                // Signing
                let hashMail = messageText.sha256()
                AsymmetricCryptoManager.sharedInstance.signMessageWithPrivateKey(hashMail) { (success, data, error) -> Void in
                    if success {
                        let b64encoded = data!.base64EncodedString(options: [])
                        print("Signed mail: \(b64encoded)")
                        message.signedMessage = b64encoded  // save signed message
                        message.writeToRealm()
                    } else {
                        print("Signing error")
                    }
                }
            } else {  // Man in the Middle is active
                let newMessage = messageText  // message in the text view
                let corruptedMessage = String(newMessage.dropLast()) /// Corrupt the message(remove the last character for test scenario)

                // Encrypting
                AsymmetricCryptoManager.sharedInstance.encryptMailWithPublicKey(mail: corruptedMessage) { (success, data, error) -> Void in
                    if success {
                        let b64encoded = data!.base64EncodedString(options: [])
                        print("Encrypted Mail : \(b64encoded)")
                        message.message = b64encoded  // save encrypted message
                        //message.hashMessage = b64encoded.sha256() // save digest of encrypted mail
                        message.rsa = true  // save state of rsa
                    } else {
                        print("Encrypting error")
                    }
                }

                // Signing
                let hashMail = messageText.sha256()
                AsymmetricCryptoManager.sharedInstance.signMessageWithPrivateKey(hashMail) { (success, data, error) -> Void in
                    if success {
                        let b64encoded = data!.base64EncodedString(options: [])  // signed message
                        print("Signed mail(active) : \(b64encoded)")
                        message.signedMessage = b64encoded  // save signed message in the text view(not corrupted message)
                        message.writeToRealm()
                    } else {
                        print("Error signing message")
                    }
                }

            }
        }
        if let navigation = self.navigationController {
            navigation.popToRootViewController(animated: true)
        }
    }
    

    
    @IBAction func sendSpamMail(_ sender: Any) {
        guard let messageText = messageTextView.text, let receiverEmail = receiver else { return }
        if let currentUser = Auth.auth().currentUser?.email {
            let message = Message()
            message.sender = currentUser
            message.receiver = receiverEmail
            
            if switchState == false {  // If switch is not selected
                message.message = encrypt(messageData: messageText)! /// save encrypted message to realm
                message.spam = true /// This mail is spam
                let hashMail = messageText.sha256()  /// hash encrypted message and save to realm
                message.hashMessage = hashMail
                message.writeToRealm()
            } else {  // If switch is selected
                let newMessage = messageText
                let corruptedMessage = String(newMessage.dropLast()) /// Corrupt the message(remove the last character for test scenario)
                message.message = encrypt(messageData: corruptedMessage)!
                message.spam = true /// This mail is spam
                let hashMail = messageText.sha256()
                // hash the mail and save to realm
                message.hashMessage = hashMail
                message.writeToRealm()
            }
        }
        if let navigation = self.navigationController {
            navigation.popToRootViewController(animated: true)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something.."
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {

            textView.text = "Write something.."
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        } else {
            return true
        }

        return false
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
            if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    

    func messageTextViewDidChange() {
           
        guard let message = messageTextView.text, !message.isEmpty else {
            self.sendAESButton.isEnabled = false
            self.sendRSAButton.isEnabled = false
            self.sendAESButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            self.sendRSAButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
            return
        }
        
        if self.pageMode == .aesMail {
            self.sendAESButton.isEnabled = true
            self.sendAESButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        } else if self.pageMode == .rsaMail {
            self.sendRSAButton.isEnabled = true
            self.sendRSAButton.setTitleColor(UIColor.white, for: UIControl.State.normal)

        }
        
        
        
        
        
        
    }
}




