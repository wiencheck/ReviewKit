//
//  File.swift
//  
//
//  Created by Adam Wienconek on 12/05/2021.
//

import Foundation
import AppConfiguration

public struct Rules {
    
    public var firstDate: Date?
    
    public var numberOfDaysBetweenAskingAttempts = 7
    
    public var shouldAskForTheSameVersionMoreThanOnce = false
    
    public var appConfigurations: [AppConfiguration] = [.release, .debug]
        
}
