//
//  EstimatedWorktime.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import Foundation

/// The formatter used to format EstimatedWorktime
/// See EstimatedWorktime.formatted
fileprivate let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.zeroFormattingBehavior = .dropLeading
    formatter.allowsFractionalUnits = false
    formatter.formattingContext = .beginningOfSentence
    formatter.unitsStyle = .full
    return formatter
}()


/// A helper struct wrapping around a number of minutes. Supports comparing and basic arithmetic.
struct EstimatedWorktime: Hashable, Equatable, Comparable, AdditiveArithmetic {
    
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
    
    // Equatable and Comparable implementation
    static func == (lhs: EstimatedWorktime, rhs: EstimatedWorktime) -> Bool {
        return lhs.totalMinutes == rhs.totalMinutes
    }
    
    static func < (lhs: EstimatedWorktime, rhs: EstimatedWorktime) -> Bool {
        return lhs.totalMinutes < rhs.totalMinutes
    }
    
    // AdditiveArithmetic implementation
    static var zero: EstimatedWorktime = .init(totalMinutes: 0)
    static func + (lhs: EstimatedWorktime, rhs: EstimatedWorktime) -> EstimatedWorktime {
        return EstimatedWorktime(totalMinutes: lhs.totalMinutes + rhs.totalMinutes)
    }
    
    static func - (lhs: EstimatedWorktime, rhs: EstimatedWorktime) -> EstimatedWorktime {
        return EstimatedWorktime(totalMinutes: lhs.totalMinutes - rhs.totalMinutes)
    }
    
    
    /// Returns an EstimatedWorktime scaled by percent.
    /// - Parameter percent: The scalar multiplied with self.
    /// - Returns: self \* percent
    func percentage(_ percent: Double) -> EstimatedWorktime {
        return EstimatedWorktime(totalMinutes: Int(Double(totalMinutes) * percent))
    }
    
    /// The EstimatedWorktime cast to a TimeInterval.
    var timeInterval: TimeInterval {
        return TimeInterval(self.totalMinutes * 60)
    }
    
    /// A formatted, localized string representing self.
    var formatted: String? {
        let dateComponents = DateComponents(calendar: .current, hour: self.hours, minute: self.minutes)
        return formatter.string(from: dateComponents)
    }
}

