//
//  Priority.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import Foundation
import SwiftUI


/// An enum containing different priorties that can be assigned to projects and tasks
enum Priority: Int, CaseIterable, Hashable, Identifiable {
    var id: Priority { self }

    // The assigned integer values are used for CoreData

    case low = -10
    case normal = 0
    case high = 10
    case urgent = 20
    
    /// The localized name of the priority for standalone use (e.g., .high -> "High")
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
    
    /// The localized name of the priority togerther with the word priority for standalone use (e.g., .high -> "High Priority")
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

// Comparable implementation for sorting
extension Priority: Comparable {
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

