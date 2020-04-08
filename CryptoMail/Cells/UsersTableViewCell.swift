//
//  UsersTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 8.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


protocol UsersTableViewCellDelegate {
    func didTappedWriteMessageButton(index: Int)
}


class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var writeMailButton: UIButton!
    
    
    var delegate: UsersTableViewCellDelegate?
    var index: IndexPath?
 
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func writeMessage(_ sender: Any) {
        delegate?.didTappedWriteMessageButton(index: (index!.row))
    }
}
