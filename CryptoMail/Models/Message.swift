//
//  Message.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import RealmSwift


class Message: Object {
    
    @objc dynamic var sender = ""
    @objc dynamic var message = ""
    @objc dynamic var receiver = ""
    
}


extension Message {
    func writeToRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
}
