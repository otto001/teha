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
    func filter(project: THProject){
        let predicates = [self.predicate, NSPredicate(format: "project == %@", project)].compactMap {$0}
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    func filter(priority: Priority) {
        let predicates = [self.predicate, NSPredicate(format: "project.priorityNumber == %d", priority.rawValue)].compactMap {$0}
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

