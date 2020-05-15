//
//  RSAMailsTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 11.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


class RSAMailsTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var signDescriptionLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var receiverLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cautionImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
