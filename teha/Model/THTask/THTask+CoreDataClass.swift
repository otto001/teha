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
    // prepare a repeating task for deletion by removing it from the repeating chain of the parent
    public override func prepareForDeletion() {
        // cancel notifications
        NotificationManager.instance.cancelPendingNotifications(for: self)
        
    }
}


extension THTask {
    
    var title: String? { self.taskDescription?.title }
    
    /// The ReminderOffset to the tasks deadline of the first reminder of the Task
    var reminderFirstOffset: ReminderOffset? {
        self.taskDescription?.reminderFirstOffset
    }
    
    /// The ReminderOffset to the tasks deadline of the second reminder of the Task 
    var reminderSecondOffset: ReminderOffset? {
        self.taskDescription?.reminderSecondOffset
    }
    
    /// The Id of the task used by LocalNotification
    var taskNotificationId: String {
        get {
            return self.objectID.uriRepresentation().absoluteString
        }
    }
    
    /// The priority assiged to the task
    var priority: Priority {
        self.taskDescription?.priority ?? .normal
    }
    
    /// The estimatedWorktime of the Task.
    var estimatedWorktime: Worktime? {
        self.taskDescription?.estimatedWorktime
    }
    
    /// True if the task was started by the user
    var isStarted: Bool { self.startDate != nil }
    
    /// True if the task was completed by the user
    var isCompleted: Bool { self.completionDate != nil }
    
    /// Marks the task as started at the current date
    func started() {
        self.startDate = .now
    }
    
    /// Marks the task as not started
    func resetStarted() {
        self.startDate = nil
        self.completionDate = nil
        self.completionProgress = 0
        NotificationManager.instance.scheduleReminderNotifications(task: self)
        GeoMonitor.shared.refreshLocationMonitoring(task: self)
    }
    
    /// Marks the task as completed at the current date
    func completed() {
        self.completionDate = .now
        self.completionProgress = 1
        
        if self.startDate == nil {
            self.startDate = self.completionDate
        }
        
        // Remove pending notifications for task
        NotificationManager.instance.cancelPendingNotifications(for: self)
        // Stop geofence
        GeoMonitor.shared.refreshLocationMonitoring(task: self)
    }
    
    /// Marks the task as not completed
    func resetCompleted() {
        self.completionDate = nil
        NotificationManager.instance.scheduleReminderNotifications(task: self)
        GeoMonitor.shared.refreshLocationMonitoring(task: self)
    }
    
    /// The remainder of the estimatedWorktime of the Task when factoring in the tasks completionProgress and the tasks completion/started state.
    var estimatedWorktimeRemaining: Worktime? {
        guard let estimatedWorktime = self.estimatedWorktime else { return nil }
        if self.isCompleted {
            return .zero
        } else if !self.isStarted {
            return estimatedWorktime
        }
        return estimatedWorktime.percentage(1 - self.completionProgress)
    }
    
    func updateFromDescription(offset: TimeInterval) {
        self.earliestStartDate = self.taskDescription?.earliestStartDate?.addingTimeInterval(offset)
        self.deadlineDate = self.taskDescription?.deadlineDate?.addingTimeInterval(offset)
        self.project = self.taskDescription?.project
    }
    
}


//MARK: FetchRequests
extension THTask {
    
    /// A fetch request fetching all tags sorted by: deadline (asc), priority (desc), creationDate (desc), title (asc)
    static var all: NSFetchRequest<THTask> {
        let request = THTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "deadlineDate", ascending: true),
                                   NSSortDescriptor(key: "taskDescription.priorityNumber", ascending: false),
                                   NSSortDescriptor(key: "creationDate", ascending: false),
                                   NSSortDescriptor(key: "taskDescription.title", ascending: true),]
        return request
    }
}


extension NSFetchRequest where ResultType == THTask {
    
    /// Modifies the predicate of the fetch request to only include tasks that are/are not completed
    /// - Parameter completed: If true, only completed tasks are inlcuded, if false, only not completed tasks are included.
    func filter(completed: Bool) {
        if completed {
            self.predicateAnd(with: NSPredicate(format: "completionDate != nil"))
        } else {
            self.predicateAnd(with: NSPredicate(format: "completionDate == nil"))
        }
    }
    
    /// Modifies the predicate of the fetch request to only include tasks of the given project.
    /// - Parameter project: The project to filter by.
    func filter(project: THProject) {
        self.predicateAnd(with: NSPredicate(format: "project == %@", project))
    }
    
    /// Modifies the predicate of the fetch request to only include tasks of the given priority.
    /// - Parameter priority: The priority to filter by.
    func filter(priority: Priority) {
        self.predicateAnd(with: NSPredicate(format: "taskDescription.priorityNumber == %d", priority.rawValue))
    }
    
    /// Modifies the predicate of the fetch request to only include tasks that have their deadline before or at the given date.
    /// - Parameter date: The date to filter by.
    func filter(deadlineBeforeEquals date: Date) {
        self.predicateAnd(with: NSPredicate(format: "deadlineDate <= %@", date as NSDate))
    }
    
    /// Modifies the predicate of the fetch request to only include tasks that have their deadline after the given date
    /// - Parameter date: The date to filter by.
    func filter(deadlineAfter date: Date) {
        self.predicateAnd(with: NSPredicate(format: "deadlineDate > %@", date as NSDate))
    }
    
    /// Little helper enum for .filter(tags:mode:)
    enum TagFilterMode {
        /// Matching tasks must include all tags
        case matchAll
        
        /// Matching tasks must include at least of the tags
        case matchAny
    }
    
    /// Modifies the predicate of the fetch request to only include tasks that have either any of all of the given tags.
    /// - Parameter tags: The tags to filter by.
    /// - Parameter mode: Whether to matches need to include at least one or all of the tags.
    func filter(tags: Set<THTag>, mode: TagFilterMode) {
        switch mode {
        case .matchAny:
            self.predicateAnd(with: NSPredicate(format: "(ANY tags IN %@)", Array(tags)))
        case .matchAll:
            // Unfortunately (ALL tags IN %@) is not supported by CoreData, so we add a bunch of ANDs. This is fine, since the user generally does not include thousands of tags.
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
        let containedPredicate = NSPredicate(format: "(%@ >= earliestStartDate AND %@ < deadlineDate)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        let rightOverlapPredicate = NSPredicate(format: "(%@ <= deadline AND %@ > deadlineDate)", dateInterval.start as NSDate, dateInterval.end as NSDate)
        
        // Case: earliestStartDate is nil and deadline is not nil
        let noBeginDatePredicate = NSPredicate(format: "earliestStartDate == nil AND %@ <= deadlineDate", dateInterval.start as NSDate)
        
        // Case: deadline is nil and earliestStartDate is not nil
        let noDeadlinePredicate = NSPredicate(format: "deadlineDate == nil AND %@ > earliestStartDate", dateInterval.end as NSDate)
        
        // Case: earliestStartDate and deadline are nil
        let bothNilPredicate = NSPredicate(format: "earliestStartDate == nil AND deadlineDate == nil")
        
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
        self.predicateAnd(with: NSPredicate(format: "(%@ <= deadlineDate AND deadlineDate < %@)", deadline.start as NSDate, deadline.end as NSDate))
    }
    
    /**
     Filters repeating tasks.
     
     - Returns:
        The filtered collection of tasks which are repeating.
    */
    func filterReoccuringTask() {
        self.predicateAnd(with: NSPredicate(format: "repeatIntervalId != 0"))
    }
    
    func filter(search: String) {
        self.predicateAnd(with: NSPredicate(format: "(title CONTAINS[cd] %@) OR (project.name CONTAINS[cd] %@) OR (notes CONTAINS[cd] %@) OR (ANY tags.name CONTAINS[cd] %@)", search, search, search, search))
    }
}

//MARK: Sectioning

extension THTask {
    // The following computed vars are used to place tasks in different sections when fetching from core data.
    
    
    /// ISO8601 string of the year, month and day of the deadline
    /// Format: "[year]-[month]-[day]"
    /// - Note: Used for sectioning tasks by day.
    @objc var deadlineDayString: String {
        guard let deadline = self.deadlineDate else { return "none" }
        return deadline.ISO8601Format(.iso8601Date(timeZone: .current))
    }
    
    /// The year and week of the deadline as a string.
    /// Format: "[year]-CW[week]"
    /// - Note: Used for sectioning tasks by calendar week.
    @objc var deadlineWeekString: String {
        guard let deadline = self.deadlineDate else { return "none" }
        let year = Calendar.current.component(.year, from: deadline)
        let week = Calendar.current.component(.weekOfYear, from: deadline)
        return "\(year)-CW\(week)"
    }
    
    /// Cropped ISO8601 string of the year and month of the deadline
    /// Format: "[year]-[month]"
    /// - Note: Used for sectioning tasks by month.
    @objc var deadlineMonthString: String {
        guard let deadline = self.taskDescription?.deadlineDate else { return "none" }
        return String(deadline.ISO8601Format(.iso8601Date(timeZone: .current)).substring(start: 0, end: 7))
    }
    
    /// The year of the deadline as a string
    /// Format: "[year]"
    /// - Note: Used for sectioning tasks by year.
    @objc var deadlineYearString: String {
        guard let deadline = self.deadlineDate else { return "none" }
        let year = Calendar.current.component(.year, from: deadline)
        return "\(year)"
    }
}
