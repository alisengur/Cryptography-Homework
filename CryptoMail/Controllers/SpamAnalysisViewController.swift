//
//  SpamAnalysisViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 10.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit

class SpamAnalysisViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mail1TextView: UITextView!
    @IBOutlet weak var mail2TextView: UITextView!
    @IBOutlet weak var mail3TextView: UITextView!
    @IBOutlet weak var mail4TextView: UITextView!
    @IBOutlet weak var mail5TextView: UITextView!
    
    @IBOutlet weak var frequencyOfMail1: UITextView!
    @IBOutlet weak var frequencyOfMail2: UITextView!
    @IBOutlet weak var frequencyOfMail3: UITextView!
    @IBOutlet weak var frequencyOfMail4: UITextView!
    @IBOutlet weak var frequencyOfMail5: UITextView!
    
    @IBOutlet weak var concatenatedForm: UITextView!
    @IBOutlet weak var frequencyOfConcatenatedForm: UITextView!
    
    @IBOutlet weak var hashOfMail1: UITextView!
    @IBOutlet weak var hashOfMail2: UITextView!
    @IBOutlet weak var hashOfMail3: UITextView!
    @IBOutlet weak var hashOfMail4: UITextView!
    @IBOutlet weak var hashOfMail5: UITextView!
    
    var concatenatedText: String?
    
    var mailOne: String?
    var mailTwo: String?
    var mailThree: String?
    var mailFour: String?
    var mailFive: String?
    
    var hashOne: String?
    var hashTwo: String?
    var hashThree: String?
    var hashFour: String?
    var hashFive: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Spam Analysis"
        mail1TextView.isScrollEnabled = false
        mail2TextView.isScrollEnabled = false
        mail3TextView.isScrollEnabled = false
        mail4TextView.isScrollEnabled = false
        mail5TextView.isScrollEnabled = false
        frequencyOfMail1.isScrollEnabled = false
        frequencyOfMail2.isScrollEnabled = false
        frequencyOfMail3.isScrollEnabled = false
        frequencyOfMail4.isScrollEnabled = false
        frequencyOfMail5.isScrollEnabled = false
        concatenatedForm.isScrollEnabled = false
        frequencyOfConcatenatedForm.isScrollEnabled = false
        hashOfMail1.isScrollEnabled = false
        hashOfMail2.isScrollEnabled = false
        hashOfMail3.isScrollEnabled = false
        hashOfMail4.isScrollEnabled = false
        hashOfMail5.isScrollEnabled = false
        
        if let mail1 = mailOne, let mail2 = mailTwo, let mail3 = mailThree, let mail4 = mailFour, let mail5 = mailFive, let concat = concatenatedText, let hashOfMailOne = hashOne, let hashOfMailTwo = hashTwo, let hashOfMailThree = hashThree, let hashOfMailFour = hashFour, let hashOfMailFive = hashFive {
            mail1TextView.text = mail1
            mail2TextView.text = mail2
            mail3TextView.text = mail3
            mail4TextView.text = mail4
            mail5TextView.text = mail5
            concatenatedForm.text = concat
            
            frequencyOfMail1.text = wordCount(mail: mail1)
            frequencyOfMail2.text = wordCount(mail: mail2)
            frequencyOfMail3.text = wordCount(mail: mail3)
            frequencyOfMail4.text = wordCount(mail: mail4)
            frequencyOfMail5.text = wordCount(mail: mail5)
            frequencyOfConcatenatedForm.text = wordCount(mail: concat)
            
            hashOfMail1.text = hashOfMailOne
            hashOfMail2.text = hashOfMailTwo
            hashOfMail3.text = hashOfMailThree
            hashOfMail4.text = hashOfMailFour
            hashOfMail5.text = hashOfMailFive
        }
    }
    
    
    func wordCount(mail: String) -> String {
        let words = mail.components(separatedBy: .whitespaces)
        var wordDictionary = Dictionary<String, Int>()
        for word in words {
            if let count = wordDictionary[word] {
                wordDictionary[word] = count + 1
            } else {
                wordDictionary[word] = 1
            }
        }
        let result = wordDictionary.map { "\($0.0)" + "=" + "\($0.1)" }.joined(separator: ";  ")
        return result
    }
}

    




