//
//  File.swift
//  
//
//  Created by Adam Wienconek on 15/05/2021.
//

import UIKit.UIApplication

struct AppConfig {
    // This is private because the use of 'current' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    // This can be used to add debug statements.
    private static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var current: UIApplication.AppConfiguration {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .test
        } else {
            return .release
        }
    }
}
