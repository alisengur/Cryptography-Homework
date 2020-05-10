//
//  DigitalSignature.swift
//  CryptoMail
//
//  Created by Ali Şengür on 6.05.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation
import CryptoKit
import Security

class DigitalSignature {
    


    func makeAndStoreKey() throws -> SecKey {
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                  [.privateKeyUsage, .biometryAny],
                                                  nil)!
        let tag = "com.example.keys.mykey".data(using: .utf8)!
        let attributes: [String: Any] = [
             kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
             kSecAttrKeySizeInBits as String: 256,
             kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
             kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access]
        ]

         var error: Unmanaged<CFError>?
         guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
             throw error!.takeRetainedValue() as Error
         }

         return privateKey
     }
    

    
    
    func sign(algorithm: SecKeyAlgorithm, data: CFData, privateKey: SecKey) throws -> Data? {
        
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    algorithm,
                                                    data as CFData,
                                                    &error) as Data? else {
                                                        throw error!.takeRetainedValue() as Error
        }
        let signedData = signature as Data
        let signedString = signedData.base64EncodedData(options: [])
        return signedString
    }
}
