//
//  RandomNumberGenerator.swift
//  CryptoMail
//
//  Created by Ali Şengür on 21.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import Foundation


class LinearCongruentialGenerator {  // Linear Congruential Generator method used for generate random number.
    
    //MARK:  formula: Rn+1 = (Rn * a + c) / m
    var lastRandomNumber: Double = 28.0
    let m = 168225.0
    let a = 8136.0
    let c = 5725.0
    
    func random() -> Double {
        lastRandomNumber = ((lastRandomNumber * a + c).truncatingRemainder(dividingBy: m))
        return lastRandomNumber / m // generate random number between 0 and 1
    }
    
}
