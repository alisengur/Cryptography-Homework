//
//  SendSpamTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 10.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


protocol SendSpamTableViewCellDelegate {
    func didTappedWriteMessageButton(index: Int)
}


class SendSpamTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var writeButton: UIButton!
    
    var delegate: SendSpamTableViewCellDelegate?
    var index: IndexPath?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        writeButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func writeButtonTapped(_ sender: Any) {
        delegate?.didTappedWriteMessageButton(index: (index!.row))
    }
}
