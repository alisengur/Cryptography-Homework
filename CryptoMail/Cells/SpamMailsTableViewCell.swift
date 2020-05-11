//
//  SpamMailsTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 10.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit

class SpamMailsTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
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

        // Configure the view for the selected state
    }
    
}
