//
//  AESEncryption.swift
//  CryptoMail
//
//  Created by Ali Şengür on 13.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import CryptoSwift


extension String {

    func aesEncrypt(key: String, iv: String) -> String? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                let encrypted = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](data))
                let encText = Data(encrypted).base64EncodedString()
                return encText
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
    
    func aesDecrypt(key: String, iv: String) -> String? {
        guard let data = Data(base64Encoded: self) else { return "" }
        do {
            let decrypted = try AES(key: key, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
            let decText = String(bytes: decrypted, encoding: .utf8)
            return decText
        } catch let error {
            print(error.localizedDescription)
        }
        return ""
    }
}
