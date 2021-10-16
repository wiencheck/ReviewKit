//
//  File.swift
//  
//
//  Created by Adam Wienconek on 12/05/2021.
//

import UIKit

extension UIColor {
    class var background: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemGroupedBackground
        }
        return .white
    }
}
