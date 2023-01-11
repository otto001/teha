//
//  Project+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//
//

import Foundation
import CoreData
import SwiftUI


@objc(THProject)
public class THProject: NSManagedObject {

}

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

extension THProject {
    
    var priority: Priority {
        get {
            return Priority(rawValue: Int(self.priorityNumber))!
        }
        set {
            self.priorityNumber = Int16(newValue.rawValue)
        }
    }
    
    var color: ColorChoice {
        get {
            return ColorChoice(rawValue: self.colorName ?? "") ?? .red
        }
        
        set {
            self.colorName = newValue.rawValue
        }
    }
}

//MARK: FetchRequests
extension THProject {
    
    static var all: NSFetchRequest<THProject> {
        let request = THProject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \THProject.priorityNumber, ascending: false),
                                   NSSortDescriptor(keyPath: \THProject.creationDate, ascending: true)]
        return request
    }
    
    static func all(completed: Bool) -> NSFetchRequest<THProject> {
        let request = self.all
        request.predicate = NSPredicate(format: "completed == %@", NSNumber(value: completed))
        return request
    }
    
    static func all(priority: Priority) -> NSFetchRequest<THProject> {
        let request = self.all
        request.predicate = NSPredicate(format: "priorityNumber == %@", priority.rawValue)
        return request
    }
    
}

