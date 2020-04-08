//
//  RealmDBOperations.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase
import FirebaseAuth

class RealmDBOperations {
    
    static var sharedInstance = RealmDBOperations()
    var realm: Realm
    
    init() {
        self.realm = try! Realm()
        print("Realm is located at:", realm.configuration.fileURL!)
    }
    
    
    func saveUser(userID: UUID, username: String, email: String, onSuccess: @escaping () -> Void){
        let user = User()
        user.username = username
        user.email = email
    }
    
}
