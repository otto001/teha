//
//  Task+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 29.12.22.
//
//

import Foundation
import CoreData

@objc(THTask)
public class THTask: NSManagedObject {

}

extension THTask {
    var priority: Priority {
        get {
            return Priority(rawValue: Int(self.priorityNumber))!
        }
        set {
            self.priorityNumber = Int16(newValue.rawValue)
        }
    }
    
    var isStarted: Bool { self.startDate != nil }
    var isCompleted: Bool { self.completionDate != nil }
}

//MARK: FetchRequests
extension THTask {
    
    static var all: NSFetchRequest<THTask> {
        let request = THTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "priorityNumber", ascending: false),
                                   NSSortDescriptor(key: "creationDate", ascending: false)]
        return request
    }
    
    static func filter(project: THProject) -> NSFetchRequest<THTask> {
        let request = THTask.all
        request.predicate = NSPredicate(format: "project == %@", project)
        return request
    }
    
}


extension NSFetchRequest where ResultType == THTask {
    func filter(project: THProject) {
        self.predicateAnd(with: NSPredicate(format: "project == %@", project))
    }
    
    func filter(priority: Priority) {
        self.predicateAnd(with: NSPredicate(format: "priorityNumber == %d", priority.rawValue))
    }
    
    enum TagFilterMode{
        case matchAll, matchAny
    }
    
    func filter(tags: Set<THTag>, mode: TagFilterMode) {
        switch mode{
        case .matchAny:
            self.predicateAnd(with: NSPredicate(format: "(ANY tags IN %@)", Array(tags)))
        case .matchAll:
            for tag in tags{
                self.predicateAnd(with: NSPredicate(format: "(ANY tags == %@)", tag))
            }
            
            
        }
        
    }
    
    
    func filter(search: String) {
        self.predicateAnd(with: NSPredicate(format: "(title CONTAINS[cd] %@) OR (project.name CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", search, search, search))
    }
   
}

