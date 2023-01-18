//
//  ReminderOffset.swift
//  teha
//
//  Created by Jette on 17.01.23.
//

import SwiftUI
import Foundation

enum ReminderOffset: Int, CaseIterable, Hashable, Identifiable {
    var id: ReminderOffset { self }
    
    case fiveMin = 5
    case tenMin = 10
    case twentyMin = 20
    case thirtyMin = 30
    case oneHour = 60
    
    var name: LocalizedStringKey {
        print("\(self.rawValue)-minutes-before")
        return LocalizedStringKey("\(self.rawValue)-minutes-before")
    }
    
}
