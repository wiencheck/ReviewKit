//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

extension UIApplication {
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown Version"
    }
    
    var appName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Unknown Name"
    }
}

extension UIApplication {
    enum AppConfiguration: Int, CustomStringConvertible {
        case debug
        case test
        case release
        
        var description: String {
            switch self {
            case .debug:    return "Debug"
            case .test:     return "Test"
            case .release:   return "Release"
            }
        }
    }
    
    var configuration: AppConfiguration {
        return AppConfig.current
    }
}
