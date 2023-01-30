//
//  RepeatInterval.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import Foundation
import SwiftUI

// The enum containing the different cases of repeating intervals
enum RepeatInterval: Int, Identifiable, CaseIterable {
    case daily = 24 // 24 hours -> 1 day
    case weekly = 168 //24*7 hours -> 1 week

    // The ID of the case saved as an Int, so it can be stored
    var id: Int { rawValue }

    // The timeInterval in seconds based on the hours of the cases
    var timeInterval: TimeInterval {
        return TimeInterval(rawValue * 3600)
    }

    // the localized String Key for each repeating Inteval case
    var name: LocalizedStringKey {
        switch self {
        case .daily: return "repeat-daily"
        case .weekly: return "repeat-weekly"
        }
    }
}

