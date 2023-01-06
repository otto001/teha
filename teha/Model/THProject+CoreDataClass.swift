//
//  Project+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//
//

import Foundation
import CoreData

@objc(THProject)
public class THProject: NSManagedObject {

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
            return "Normal"
        case .high:
            return "High"
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
    
    static func all(priority: Priority) -> NSFetchRequest<THProject> {
        let request = self.all
        request.predicate = NSPredicate(format: "priorityNumber == %@", priority.rawValue)
        return request
    }
    
}

