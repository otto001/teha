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
    var reminderOffset: ReminderOffset? {
        get {
            if let reminderMin=self.reminderMin {
                return ReminderOffset(rawValue: Int(truncating: reminderMin))
            } else {
                return nil
            }
        }
        set {
            if let newValue=newValue {
                self.reminderMin = NSNumber(value:newValue.rawValue)
            } else {
                self.reminderMin = nil
            }
        }
    }
}

//MARK: FetchRequests
extension THTask {
    
    static var all: NSFetchRequest<THTask> {
        let request = THTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "project.priorityNumber", ascending: false)]
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
        self.predicateAnd(with: NSPredicate(format: "project.priorityNumber == %d", priority.rawValue))
    }
    
    func filter(search: String) {
        self.predicateAnd(with: NSPredicate(format: "(title CONTAINS[cd] %@) OR (project.name CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@)", search, search, search))
    }
}

