//
//  Worktime.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import Foundation

/// The formatter used to format Worktime
/// See Worktime.formatted
fileprivate let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.zeroFormattingBehavior = .dropAll
    formatter.allowsFractionalUnits = false
    formatter.formattingContext = .beginningOfSentence
    formatter.unitsStyle = .full
    return formatter
}()

/// The formatter used to format Worktime
/// See Worktime.formatted
fileprivate let formatterShort: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.zeroFormattingBehavior = .dropAll
    formatter.allowsFractionalUnits = false
    formatter.formattingContext = .beginningOfSentence
    formatter.unitsStyle = .abbreviated
    return formatter
}()



/// A helper struct wrapping around a number of minutes. Supports comparing and basic arithmetic.
struct Worktime: Hashable, Equatable, Comparable, AdditiveArithmetic {
    
    /// The total number of minutes (includes hours by factor 60).
    var totalMinutes: Int
    
    /// The number of hours.
    var hours: Int {
        totalMinutes/60
    }
    
    /// The number of minutes (modulo 60).
    var minutes: Int {
        totalMinutes%60
    }
    
    init(totalMinutes: Int) {
        self.totalMinutes = totalMinutes
    }
    
    init(hours: Int, minutes: Int) {
        self.totalMinutes = hours * 60 + minutes
    }
    
    init(timeInterval: TimeInterval) {
        self.totalMinutes = Int(timeInterval/60)
    }
    
    /// Init by extracting hours and minutes from current date using given calendar
    init(extractFrom date: Date, calender: Calendar = Calendar.current) {
        let hours = calender.component(.hour, from: date)
        let minutes = calender.component(.minute, from: date)
        self.init(hours: hours, minutes: minutes)
    }
    
    // Equatable and Comparable implementation
    static func == (lhs: Worktime, rhs: Worktime) -> Bool {
        return lhs.totalMinutes == rhs.totalMinutes
    }
    
    static func < (lhs: Worktime, rhs: Worktime) -> Bool {
        return lhs.totalMinutes < rhs.totalMinutes
    }
    
    // AdditiveArithmetic implementation
    static var zero: Worktime = .init(totalMinutes: 0)
    static func + (lhs: Worktime, rhs: Worktime) -> Worktime {
        return Worktime(totalMinutes: lhs.totalMinutes + rhs.totalMinutes)
    }
    
    static func - (lhs: Worktime, rhs: Worktime) -> Worktime {
        return Worktime(totalMinutes: lhs.totalMinutes - rhs.totalMinutes)
    }
    
    
    /// Returns an Worktime scaled by percent.
    /// - Parameter percent: The scalar multiplied with self.
    /// - Returns: self \* percent
    func percentage(_ percent: Double) -> Worktime {
        return Worktime(totalMinutes: Int(Double(totalMinutes) * percent))
    }
    
    /// The Worktime cast to a TimeInterval.
    var timeInterval: TimeInterval {
        return TimeInterval(self.totalMinutes * 60)
    }
    
    /// A formatted, localized string representing self.
    var formatted: String? {
        let dateComponents = DateComponents(calendar: .current, hour: self.hours, minute: self.minutes)
        return formatter.string(from: dateComponents)
    }
    
    /// A formatted, localized string representing self.
    var formattedShort: String? {
        let dateComponents = DateComponents(calendar: .current, hour: self.hours, minute: self.minutes)
        return formatterShort.string(from: dateComponents)
    }
}

extension Worktime: RawRepresentable {
    typealias RawValue = Int
    
    init(rawValue: Int) {
        self.init(totalMinutes: rawValue)
    }
    
    var rawValue: Int {
        self.totalMinutes
    }
}
