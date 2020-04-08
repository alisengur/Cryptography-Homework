//
//  User.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    @objc dynamic var username = ""
    @objc dynamic var email = ""
    
    override static func primaryKey() -> String {
        return "username"
    }
    
}


extension User {
    func writeToRealm(){
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: .all)
            print("Realm is located at:", realm.configuration.fileURL!)
        }
    }
}
