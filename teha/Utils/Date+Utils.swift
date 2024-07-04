//
//  Date+Utils.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import Foundation

extension Date {
//    /// Add a TimeInterval to the Date
//    static func +(lhs: Date, rhs: TimeInterval) -> Date {
//        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate + rhs)
//    }
//    
//    /// Subtract a TimeInterval from the Date
//    static func -(lhs: Date, rhs: TimeInterval) -> Date {
//        return Date(timeIntervalSinceReferenceDate: lhs.timeIntervalSinceReferenceDate - rhs)
//    }
    
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


extension Date {
    /// ISO8601 string of the year, month and day of the date
    /// Format: "[year]-[month]-[day]"
    /// - Note: Used for sectioning tasks by day.
    func formatCalendarYearMonthDay(calendar: Calendar = .current) -> String {
        "\(calendar.component(.year, from: self))-\(calendar.component(.month, from: self))-\(calendar.component(.day, from: self))"
    }
    
    /// The year and week of the date as a string.
    /// Format: "[year]-CW[week]"
    /// - Note: Used for sectioning tasks by calendar week.
    func formatCalendarYearWeek(calendar: Calendar = .current) -> String {
        "\(calendar.component(.year, from: self))-CW\(calendar.component(.weekOfYear, from: self))"
    }
    
    /// Cropped ISO8601 string of the year and month of the date
    /// Format: "[year]-[month]"
    /// - Note: Used for sectioning tasks by month.
    func formatCalendarYearMonth(calendar: Calendar = .current) -> String {
        "\(calendar.component(.year, from: self))-\(calendar.component(.month, from: self))"
    }
    
    /// The year of the date as a string
    /// Format: "[year]"
    /// - Note: Used for sectioning tasks by year.
    func formatCalendarYear(calendar: Calendar = .current) -> String {
        "\(calendar.component(.year, from: self))"
    }
}
