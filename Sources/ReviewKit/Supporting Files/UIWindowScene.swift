//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import UIKit

@available (iOS 13.0, *)
extension UIWindowScene {
    static var focused: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first {
                $0.activationState == .foregroundActive && $0 is UIWindowScene
            } as? UIWindowScene
    }
}
