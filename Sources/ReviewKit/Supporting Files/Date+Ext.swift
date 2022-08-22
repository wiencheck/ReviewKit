//
//  File 2.swift
//  
//
//  Created by Adam Wienconek on 11/05/2021.
//

import Foundation

extension Date {
    func daysBetween(end: Date) -> Int {
        return Calendar.current.dateComponents([.day],
                                               from: self,
                                               to: end).day ?? 0
    }
}
