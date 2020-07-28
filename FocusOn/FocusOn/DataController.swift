//
//  DataController.swift
//  FocusOn
//
//  Created by Matthew Sousa on 3/2/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import CoreData

class DataController: DateManager {
    
    
    // Generate ID - With numbers and letters
    func genID() -> String {
        let letters = ["A", "B", "C", "D", "E", "F",
                       "G", "H", "I", "J", "K", "L",
                       "M", "N", "O", "P", "Q", "R",
                       "S", "T", "U", "V", "W", "X",
                       "Y", "Z"]
        // desired ID length
        let idLength = 5
        // tempID
        var id: String = ""
        // for 1 - idLength choose a random number
        for _ in 1...idLength {
            let x = Int.random(in: 0...10000)
            // if x is more than 5000 choose a letter
            if x >= 5000 {
                let chosenLetter = letters[Int.random(in: 0..<letters.count)]
                id += chosenLetter
            } else { // choose a number between 0 - 9
                let chosenInt = "\(Int.random(in: 0..<9))"
                id += chosenInt
            }
        }
        return id
    }
    
  
    
}


