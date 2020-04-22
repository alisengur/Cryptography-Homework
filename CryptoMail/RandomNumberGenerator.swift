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
    var lastRandomNumber = Double.random(in: 1...100) // Seed number.
    //The sequence depends on the seed. If seed number isn't a random, next sequence may not be different.
    let m = 25371.0
    let a = 965.0
    let c = 9712.0
    
    func random() -> Double {
        lastRandomNumber = ((lastRandomNumber * a + c).truncatingRemainder(dividingBy: m))
        return lastRandomNumber / m // generate random number between 0 and 1
    }
    
}
