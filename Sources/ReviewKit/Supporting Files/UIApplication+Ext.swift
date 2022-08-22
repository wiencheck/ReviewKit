//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

extension UIApplication {
    
    var appName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Unknown Name"
    }
    
}
