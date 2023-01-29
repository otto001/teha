//
//  Date+Utils.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import Foundation

extension Date {
    /// Add a TimeInterval to the Date
    static func +(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate + rhs)
    }
    
    /// Subtract a TimeInterval from the Date
    static func -(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate - rhs)
    }
}

