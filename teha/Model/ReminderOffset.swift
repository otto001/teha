//
//  ReminderOffset.swift
//  teha
//
//  Created by Jette on 17.01.23.
//

import SwiftUI
import Foundation

/**
 ReminderOffset is an enumeration that represents different time offsets that can be used to set a reminder given a deadline.
 
 Each case represents an offset in minutes, and has an associated name, which is a string that describes the offset in readable format.
*/
enum ReminderOffset: Int, CaseIterable, Hashable, Identifiable, Comparable {

    
    var id: ReminderOffset { self }
    
    case fiveMinutes = 5
    case tenMinutes = 10
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case oneDay = 1440
    case twoDays = 2880
    case oneWeek = 10080
    
    
    // Comparable Implementation
    static func < (lhs: ReminderOffset, rhs: ReminderOffset) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    /**
     The name computed property returns a LocalizedStringKey that describes the offset in readable format.
     The format is based on the rawValue of the case, it will return a LocalizedStringKey with "minutes", "hour\(s)", "day\(s)" or "week\(s)" depending on the rawValue of the case.
     - Returns: LocalizedStringKey
    */
    var name: LocalizedStringKey {
        if self < .oneHour {
            return LocalizedStringKey("\(self.rawValue)-minutes-before-deadline")
        } else if self < .oneDay {
            return LocalizedStringKey("\(self.rawValue / ReminderOffset.oneHour.rawValue)-hours-before-deadline")
        } else if self < .oneWeek {
            return LocalizedStringKey("\(self.rawValue / ReminderOffset.oneDay.rawValue)-days-before-deadline")
        } else {
            return LocalizedStringKey("\(self.rawValue / ReminderOffset.oneWeek.rawValue)-weeks-before-deadline")
        }
    }
    
}
