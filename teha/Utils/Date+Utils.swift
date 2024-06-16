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
    
    /// The the date of the first day of the week of self
    /// Respects the users locale
    var startOfWeek: Date {
        var components = Calendar.current.dateComponents([.weekday, .year, .month, .weekOfYear], from: self)
        components.weekday = Calendar.current.firstWeekday
        return Calendar.current.date(from: components)!
    }
    
    /// The the date of the first day of the week of self
    /// Respects the users locale
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

