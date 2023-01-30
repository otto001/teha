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
    
    /// The ReminderOffset to the tasks deadline of the first reminder of the Task
    var reminderOffset: ReminderOffset? {
        get {
            self.reminderMin.flatMap { ReminderOffset(rawValue: Int(truncating: $0)) }
        }
        set {
            self.reminderMin = (newValue?.rawValue).map { NSNumber(value: $0) }
        }
    }
    
    /// The ReminderOffset to the tasks deadline of the second reminder of the Task 
    var reminderOffsetSecond: ReminderOffset? {
        get {
            self.reminderMinSecond.flatMap { ReminderOffset(rawValue: Int(truncating: $0)) }
        }
        set {
            self.reminderMinSecond = (newValue?.rawValue).map { NSNumber(value: $0) }
        }
    }
    
    /// The Id of the task used by LocalNotification
    var taskNotificationId: String {
        get {
            return self.objectID.uriRepresentation().absoluteString
        }
    }
    
    var priority: Priority {
        get {
            return Priority(rawValue: Int(self.priorityNumber))!
        }
        set {
            self.priorityNumber = Int16(newValue.rawValue)
        }
    }
    
    /// The estimatedWorktime of the Task.
    var estimatedWorktime: Worktime {
        get {
            return Worktime(totalMinutes: Int(self.estimatedWorktimeMinutes))
        }
        set {
            self.estimatedWorktimeMinutes = Int16(newValue.totalMinutes)
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
        
        // Remove pending notifications for task
        NotificationManager.instance.cancelPendingNotifications(for: self)
    }
    
    /// The remainder of the estimatedWorktime of the Task when factoring in the tasks completionProgress and the tasks completion/started state.
    var estimatedWorktimeRemaining: Worktime {
        if self.isCompleted {
            return .zero
        } else if !self.isStarted {
            return self.estimatedWorktime
        }
        return self.estimatedWorktime.percentage(1 - self.completionProgress)
    }
}


//MARK: FetchRequests
extension THTask {
    
    static var all: NSFetchRequest<THTask> {
        let request = THTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true),
                                   NSSortDescriptor(key: "priorityNumber", ascending: false),
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
    
    func filter(deadlineBeforeEquals date: Date) {
        self.predicateAnd(with: NSPredicate(format: "deadline <= %@", date as NSDate))
    }
    
    func filter(deadlineAfter date: Date) {
        self.predicateAnd(with: NSPredicate(format: "deadline > %@", date as NSDate))
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
        let leftOverlapPredicate = NSPredicate(format: "(%@ <= earliestStartDate AND %@ > earliestStartDate)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        let containedPredicate = NSPredicate(format: "(%@ >= earliestStartDate AND %@ < deadline)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        let rightOverlapPredicate = NSPredicate(format: "(%@ <= deadline AND %@ > deadline)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        
        // Case: earliestStartDate is nil and deadline is not nil
        let noBeginDatePredicate = NSPredicate(format: "earliestStartDate == nil AND %@ <= deadline", dateInterval.start as NSDate)
        
        // Case: deadline is nil and earliestStartDate is not nil
        let noDeadlinePredicate = NSPredicate(format: "deadline == nil AND %@ > earliestStartDate", dateInterval.end as NSDate)
        
        // Case: earliestStartDate and deadline are nil
        let bothNilPredicate = NSPredicate(format: "earliestStartDate == nil AND deadline == nil")
        
        let allCases = NSCompoundPredicate(orPredicateWithSubpredicates: [leftOverlapPredicate, containedPredicate, rightOverlapPredicate, noBeginDatePredicate, noDeadlinePredicate, bothNilPredicate])
        self.predicateAnd(with: allCases)
    }
    
    /**
     Filters tasks based on a given deadline date interval.
     
     - Parameters:
        - deadline: The date interval used to filter tasks. Only tasks with deadlines falling within this interval will be included.
     
     - Returns:
        The filtered collection of tasks with deadlines falling within the given date interval.
    */
    func filter(deadline: DateInterval) {
        self.predicateAnd(with: NSPredicate(format: "(%@ <= deadline AND deadline < %@)", deadline.start as NSDate, deadline.end as NSDate))
    }
    
    func filter(search: String) {
        self.predicateAnd(with: NSPredicate(format: "(title CONTAINS[cd] %@) OR (project.name CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@) OR (ANY tags.name CONTAINS[cd] %@)", search, search, search, search))
    }
}

//MARK: Sectioning
extension THTask {
    
    /// ISO8601 string of the year, month and day of the deadline
    /// Format: "[year]-[month]-[day]"
    @objc var deadlineDayString: String {
        guard let deadline = self.deadline else { return "none" }
        return deadline.ISO8601Format(.iso8601Date(timeZone: .current))
    }
    
    /// The year and week of the deadline as a string.
    /// Format: "[year]-CW[week]"
    @objc var deadlineWeekString: String {
        guard let deadline = self.deadline else { return "none" }
        let year = Calendar.current.component(.year, from: deadline)
        let week = Calendar.current.component(.weekOfYear, from: deadline)
        return "\(year)-CW\(week)"
    }
    
    /// Cropped ISO8601 string of the year and month of the deadline
    /// Format: "[year]-[month]"
    @objc var deadlineMonthString: String {
        guard let deadline = self.deadline else { return "none" }
        return String(deadline.ISO8601Format(.iso8601Date(timeZone: .current)).substring(start: 0, end: 7))
    }
    
    /// The year of the deadline as a string
    /// Format: "[year]"
    @objc var deadlineYearString: String {
        guard let deadline = self.deadline else { return "none" }
        let year = Calendar.current.component(.year, from: deadline)
        return "\(year)"
    }
}
