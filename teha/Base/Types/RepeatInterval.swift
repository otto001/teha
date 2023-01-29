//
//  RepeatInterval.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import Foundation
import SwiftUI


enum RepeatInterval: Int, Identifiable, CaseIterable {
    case daily = 24 // 24 hours -> 1 day
    case weekly = 168 //24*7 hours -> 1 week
    
    var id: Int { rawValue }
    
    var timeInterval: TimeInterval {
        return TimeInterval(rawValue * 3600)
    }
    
    var name: LocalizedStringKey {
        switch self {
        case .daily: return "repeat-daily"
        case .weekly: return "repeat-weekly"
        }
    }
}

