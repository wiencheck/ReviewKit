//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/09/2022.
//

import Foundation

extension String {
    
    static func random(usingCharacters allowedCharacters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", length: Int) -> String {
        return allowedCharacters
            .shuffled()
            .prefix(length)
            .map { String($0) }
            .joined()
    }
    
}
