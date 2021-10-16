//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

struct DefaultMessages {
    static var titleNotDetermined: String {
        return "How do you like \(UIApplication.shared.appName) so far?"
    }
    
    static var titlePositive: String {
        return "That's great!"
    }
    
    static var titleNegative: String {
        return "What could be improved?"
    }
    
    static var messageNotDetermined: String {
        return "Your opinion is very important to us, so whether you like the app or not, we want to know!"
    }
    
    static var messagePositive: String {
        return "Your review keeps us motivated to make an even better app and helps grow the userbase!"
    }
    
    static var messageNegative: String {
        return "We would love to hear your feedback to better understand what could be improved!"
    }
    
    static var primaryButtonNotDetermined: String {
        return "Loving it! 😍"
    }
    
    static var primaryButtonPositive: String {
        return "Write a review 🌟"
    }
    
    static var secondaryButtonNotDetermined: String {
        return "Could be better 😕"
    }
    
    static var secondaryButtonNegative: String {
        return "Contact us"
    }
    
    static var tertiaryButton: String {
        return "Maybe later"
    }
}
