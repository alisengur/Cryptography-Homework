//
//  DetailWatermarkViewController.swift
//  CryptoMail
//
//  Created by Ali Şengür on 14.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit

class DetailWatermarkViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Image Details"
        if let imageData = self.imageData {
            self.imageView.image = UIImage(data: imageData)
        }
    }
    



}
