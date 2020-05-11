//
//  UsersTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 8.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
