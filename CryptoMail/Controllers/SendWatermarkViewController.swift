//
//  SendWatermarkViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 13.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase


class SendWatermarkViewController: UIViewController {

    @IBOutlet weak var watermarkTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var addWatermarkButton: UIButton!
    
    var nameTitle: String?
    var receiver: String?
    var imageData: Data?
    var key: Results<Key>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nameTitle
        self.sendButton.layer.cornerRadius = 5
        self.addWatermarkButton.layer.cornerRadius = 5
        self.imageView.image = UIImage(named: "monalisa")
        
        let realm = try! Realm()
        key = realm.objects(Key.self)
    }
    
    
    @IBAction func addWatermarkToImage(_ sender: Any) {
        if let watermarkText = self.watermarkTextField.text, watermarkText.count > 0 {
            let newImage = textToImage(drawText: watermarkText as NSString, inImage: UIImage(named: "monalisa")!, atPoint: CGPoint(x: 20, y: 20))
            self.imageView.image = newImage
        }
        
    }
    
    @IBAction func sendImageWithWatermark(_ sender: Any) {

        if let currentUser = Auth.auth().currentUser?.email, let receiverEmail = receiver {
            let message = Message()
            message.sender = currentUser
            message.receiver = receiverEmail
            message.aes = true
            
            let image = UIImage(named: "monalisa")
            let pngData = image?.pngData()!
            message.imageData = pngData
            if let watermarkText = self.watermarkTextField.text, watermarkText.count > 0 {
                let watermarkImage = textToImage(drawText: watermarkText as NSString, inImage: UIImage(named: "monalisa")!, atPoint: CGPoint(x: 20, y: 20))
                let watermarkImgData = watermarkImage.pngData()!
                message.watermarkImageData = watermarkImgData
                message.watermark = encrypt(messageData: watermarkText)
                message.writeToRealm()
            }
        }
        if let navigation = self.navigationController {
            navigation.popToRootViewController(animated: true)
        }
    }
    
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.white
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 42)!

        UIGraphicsBeginImageContext(inImage.size)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]

        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        let rect: CGRect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)

        //Draw the text into an image.
        drawText.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //And pass it back up to the caller.
        return newImage

    }
    
    func encrypt(messageData: String) -> String? {
        let encryptedMessage = messageData.aesEncrypt(key: key[0].key, iv: "1234567812345678")
        return encryptedMessage
    }


}
