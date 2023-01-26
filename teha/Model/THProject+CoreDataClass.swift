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
            return ColorChoice(rawValue: self.colorCode ?? "") ?? .red
        }
        
        set {
            self.colorCode = newValue.rawValue
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

