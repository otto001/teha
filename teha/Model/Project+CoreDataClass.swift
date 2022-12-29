//
//  Project+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject {

}

enum Priority: Int, CaseIterable, Hashable, Identifiable {
    var id: Priority { self }
    
    case low = -10
    case def = 0
    case high = 10
    
    var name: String {
        switch self {
        case .low:
            return "Low"
        case .def:
            return "Default"
        case .high:
            return "High"
        }
    }
}

extension Project {
    
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
extension Project {
    
    static var all: NSFetchRequest<Project> {
        let request = Project.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.priorityNumber, ascending: false)]
        return request
    }
    
    static func all(priority: Priority) -> NSFetchRequest<Project> {
        let request = self.all
        request.predicate = NSPredicate(format: "priorityNumber == %@", priority.rawValue)
        return request
    }
    
}

