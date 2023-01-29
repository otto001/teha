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
    
    func started() {
        self.startDate = .now
    }
    
    func completed() {
        self.completionDate = .now
        self.completionProgress = 1
        
        if self.startDate == nil {
            self.startDate = self.completionDate
        }
    }
}

//MARK: FetchRequests
extension THTask {
    
    static var all: NSFetchRequest<THTask> {
        let request = THTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "priorityNumber", ascending: false),
                                   NSSortDescriptor(key: "creationDate", ascending: false),
                                   NSSortDescriptor(key: "title", ascending: true),]
        return request
    }
    
    static func filter(project: THProject) -> NSFetchRequest<THTask> {
        let request = THTask.all
        request.predicate = NSPredicate(format: "project == %@", project)
        return request
    }
    
}


extension NSFetchRequest where ResultType == THTask {
    
    func filter(completed: Bool) {
        if completed {
            self.predicateAnd(with: NSPredicate(format: "completionDate != nil"))
        } else {
            self.predicateAnd(with: NSPredicate(format: "completionDate == nil"))
        }
    }
    
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
        switch mode {
        case .matchAny:
            self.predicateAnd(with: NSPredicate(format: "(ANY tags IN %@)", Array(tags)))
        case .matchAll:
            for tag in tags {
                self.predicateAnd(with: NSPredicate(format: "(ANY tags == %@)", tag))
            }
        }
    }
    
    /**
        Filters the tasks based on the provided date interval. 
     
        Predicates are created for 4 different cases:
            - Case 1: `earliestStartDate` and `deadline` are not `nil`
                There is an overlap between [`earliestStartDate`, `deadline`] and the provided `dateInterval`.
            - Case 2: `earliestStartDate` is `nil` and `deadline` is not `nil`
                If there is no `earliestStartDate`, then the provided `dateInterval.begin` should be before `deadline`.
            - Case 3: `deadline` is `nil` and `earliestStartDate` is not `nil`
                If there is no `deadline`, then the provided `dateInterval.end` should be before `earliestStartDate`.
            - Case 4: `earliestStartDate` and `deadline` are `nil`
                The task can be returned since there are no constraints.

        The predicates are combined by OR-ing them using a compound predicate (`NSCompoundPredicate`), and the filter is applied to the fetch request.

        - Parameters:
         - dateInterval: The date interval in which the task can be completed.
     
    */
    func filter(dateInterval: DateInterval) {
        // Case: earliestStartDate and deadline are not nil
        let leftOverlapPredicate = NSPredicate(format: "(%@ <= earliestStartDate AND %@ >= earliestStartDate)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        let containedPredicate = NSPredicate(format: "(%@ >= earliestStartDate AND %@ <= deadline)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        let rightOverlapPredicate = NSPredicate(format: "(%@ <= deadline AND %@ >= deadline)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        
        // Case: earliestStartDate is nil and deadline is not nil
        let noBeginDatePredicate = NSPredicate(format: "earliestStartDate == nil AND %@ <= deadline", dateInterval.start as NSDate)
        
        // Case: deadline is nil and earliestStartDate is not nil
        let noDeadlinePredicate = NSPredicate(format: "deadline == nil AND %@ >= earliestStartDate", dateInterval.end as NSDate)
        
        // Case: earliestStartDate and deadline are nil
        let bothNilPredicate = NSPredicate(format: "earliestStartDate == nil AND deadline == nil")
        
        let allCases = NSCompoundPredicate(orPredicateWithSubpredicates: [leftOverlapPredicate, containedPredicate, rightOverlapPredicate, noBeginDatePredicate, noDeadlinePredicate, bothNilPredicate])
        self.predicateAnd(with: allCases)
    }
    
    func filter(search: String) {
        self.predicateAnd(with: NSPredicate(format: "(title CONTAINS[cd] %@) OR (project.name CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@) OR (ANY tags.name CONTAINS[cd] %@)", search, search, search, search))
    }
}

