//
//  AuthService.swift
//  CryptoMail
//
//  Created by Ali Şengür on 7.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.


import Foundation
import FirebaseAuth
import FirebaseDatabase


class AuthService {
    
    
    //MARK: -Sign In Function
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: AuthErrorCode) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    print("failed")
                    onError(errorCode)
                }
            }
            if user != nil {
                print("succeeded")
                onSuccess()
            }
        })
    }

    
    
    
    //MARK: -Sign Up Function
    static func signUp(email: String, username: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: AuthErrorCode) -> Void) {
        
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {  // We can access all errors with AuthErrorCode
                    print("failed")
                    onError(errorCode)
                }
            }
            if user != nil {
              onSuccess()
              let uid = user?.user.uid
              self.setUserInformation(username: username, email: email, uid: uid!, onSuccess: onSuccess)
            }
        })
    }
    
    
    
    static func setUserInformation(username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["username": username, "email": email])
        print("description : \(newUserReference.description())")
        onSuccess()
    }
    
}
