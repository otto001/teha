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
enum ReminderOffset: Int, CaseIterable, Hashable, Identifiable {
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
    
    /**
     The name computed property returns a LocalizedStringKey that describes the offset in readable format.
     The format is based on the rawValue of the case, it will return a LocalizedStringKey with "minutes", "hour\(s)", "day\(s)" or "week\(s)" depending on the rawValue of the case.
     - Returns: LocalizedStringKey
    */
    var name: LocalizedStringKey {
        let value = self.rawValue
        let minutes = NSLocalizedString("%d-minutes-before", comment: "")
        let hour = NSLocalizedString("%d-hour-before", comment: "")
        let hours = NSLocalizedString("%d-hours-before", comment: "")
        let day = NSLocalizedString("%d-day-before", comment: "")
        let days = NSLocalizedString("%d-days-before", comment: "")
        let week = NSLocalizedString("%d-week-before", comment: "")
        let weeks = NSLocalizedString("%d-weeks-before", comment: "")

        if value < 60 {
            return LocalizedStringKey(String(format: minutes, value))
        } else if value < 1440 {
            return LocalizedStringKey(String(format: (value / 60) == 1 ? hour : hours, value / 60))
        } else if value < 10080 {
            return LocalizedStringKey(String(format: (value / 1440) == 1 ? day : days, value / 1440))
        } else {
            return LocalizedStringKey(String(format: (value / 10080) == 1 ? week : weeks, value / 10080))
        }
    }
    
//    // This does not work because the replacement of %d placeholders happens on the localized string, not on the key.
//    // We therefore need to introduce %d placeholders in the return value. Nevertheless, a string which is to be interpolated
//    // shows weired behavior when passed to LocalizedStringKey()
//    var name: LocalizedStringKey {
//        let value = self.rawValue
//
//        if value < 60 {
//            let fiveMin = "\(value)-minute\(value > 1 ? "s" : "")-before"
//            return LocalizedStringKey(fiveMin)
////            return LocalizedStringKey("5-minutes-before")
//        } else if value < 1440 {
//            return LocalizedStringKey("\(value/60)-hour\(value/60 > 1 ? "s" : "")-before")
//        } else if value < 10080 {
//            return LocalizedStringKey("\(value/1440)-day\(value/1440 > 1 ? "s" : "")-before")
//        } else {
//            return LocalizedStringKey("\(value/10080)-week\(value/10080 > 1 ? "s" : "")-before")
//        }
//    }

    
}
