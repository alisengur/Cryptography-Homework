//
//  Keys.swift
//  CryptoMail
//
//  Created by Ali Şengür on 14.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import RealmSwift

class Key: Object {
    @objc dynamic var key = ""
}

extension Key {
    func writeToRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
}
