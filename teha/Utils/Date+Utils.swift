//
//  Date+Utils.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import Foundation

extension Date {
    static func +(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate + rhs)
    }
    
    static func -(lhs: Date, rhs: TimeInterval) -> Date {
        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate - rhs)
    }
}
