//
//  DetailMailViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 22.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit

class DetailMailViewController: UIViewController {

    @IBOutlet weak var mailTitleLabel: UILabel!
    @IBOutlet weak var mailTextView: UITextView!
    @IBOutlet weak var mailDescriptionLabel: UILabel!
    
    var mailTitle: String?
    var mailText: String?
    var mailDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTextView.delegate = self
        self.mailDescriptionLabel.layer.cornerRadius = 5
        mailTitleLabel.text = self.mailTitle
        mailTextView.text = self.mailText
        mailDescriptionLabel.text = self.mailDescription
        self.mailTextView.isScrollEnabled = false
        textViewDidChange(mailTextView)
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
