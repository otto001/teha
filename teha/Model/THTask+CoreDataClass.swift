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


// MARK: Repeating
extension THTask {
    
    var repeatInterval: RepeatInterval? {
        get {
            guard self.repeatIntervalId != 0 else { return nil }
            return RepeatInterval(rawValue: Int(self.repeatIntervalId))
        }
        set {
            self.repeatIntervalId = Int32(newValue?.rawValue ?? 0)
        }
    }
    
    var isRepeating: Bool {
        self.repeatInterval != nil
    }
    
    var isRepeatingParent: Bool {
        return (self.repeatingChildren?.count ?? 0) > 0
    }
    
    var isRepeatingChild: Bool {
        return self.repeatingParent != nil
    }
    
    var repeatingSiblings: Set<THTask>? {
        if isRepeatingParent {
            var result = self.repeatingChildren as? Set<THTask>
            result?.insert(self)
            return result
        } else if isRepeatingChild {
            return self.repeatingParent?.repeatingSiblings
        }
        return nil
    }
    
    private func makeRepeatingSibling(managedObjectContext: NSManagedObjectContext, timeshift: TimeInterval) -> THTask? {
        guard let deadline = self.deadline else { return nil }
        
        let sibling = THTask(context: managedObjectContext)
        
        for (propertyName, _) in self.entity.propertiesByName {
            sibling.setValue(self.value(forKey: propertyName), forKey: propertyName)
        }
        
        sibling.creationDate = .now
        sibling.deadline = deadline + timeshift
        
        if let earliestStartDate = self.earliestStartDate {
            sibling.earliestStartDate = earliestStartDate + timeshift
        }
        
        return sibling
    }
    
    @discardableResult
    func updateRepeating(managedObjectContext: NSManagedObjectContext?) -> Bool {

        guard let managedObjectContext = managedObjectContext ?? self.managedObjectContext else {
            return false
        }
        
            // TODO: FIX< SKIP SELF AND PARENT??
//        if let currentSiblings = self.repeatingSiblings {
//            for sibling in currentSiblings {
//                managedObjectContext.delete(sibling)
//            }
//        }
        
        guard let stepsize = self.repeatInterval?.timeInterval, self.deadline != nil else {
            return true
        }
        
        for i in 0..<10 {
            let sibling = self.makeRepeatingSibling(managedObjectContext: managedObjectContext, timeshift: Double(i+1)*stepsize)
            sibling?.repeatingParent = self
        }
        
        return true
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
