//
//  Priority.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import Foundation
import SwiftUI


enum Priority: Int, CaseIterable, Hashable, Identifiable {
    var id: Priority { self }
    
    case low = -10
    case normal = 0
    case high = 10
    case urgent = 20
    
    var name: LocalizedStringKey {
        switch self {
        case .low:
            return "low"
        case .normal:
            return "normal"
        case .high:
            return "high"
        case .urgent:
            return "urgent"
        }
    }
    
    var nameWithPriority: LocalizedStringKey {
        switch self {
        case .low:
            return "low-priority"
        case .normal:
            return "normal-priority"
        case .high:
            return "high-priority"
        case .urgent:
            return "urgent-priority"
        }
    }
}

extension Priority: Comparable {
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

