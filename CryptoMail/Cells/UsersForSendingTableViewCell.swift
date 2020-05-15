//
//  UsersForSendingTableViewCell.swift
//  CryptoMail
//
//  Created by Ali Şengür on 11.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


protocol UsersForSendingTableViewCellDelegate {
    func didTappedWriteMessageButton(index: Int)
    func sendImageButtonDidTapped(index: Int)
}


class UsersForSendingTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var sendImageButton: UIButton!
    
    var delegate: UsersForSendingTableViewCellDelegate?
    var index: IndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        writeButton.layer.cornerRadius = 5
        sendImageButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func writeButtonTapped(_ sender: Any) {
        delegate?.didTappedWriteMessageButton(index: (index!.row))
    }
    
    @IBAction func sendImageButtonDidTapped(_ sender: Any) {
        delegate?.sendImageButtonDidTapped(index: (index!.row))
    }
}
