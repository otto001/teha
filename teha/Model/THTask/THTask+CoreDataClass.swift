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
    func taskNotificationId(reminderIndex i: Int) -> String {
        self.objectID.uriRepresentation().absoluteString + "/reminder/\(i)"
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
    
    func updateProgressFromLogs() {
        guard let estimatedWorktime = self.estimatedWorktime, estimatedWorktime > .zero else { return }
        let totalMinutesLogged = Double(self.timeLogEntries.reduce(0) { $0 + $1.timeMinutes })
        let progress = max(0, min(1, totalMinutesLogged/Double(estimatedWorktime.totalMinutes)))
        self.completionProgress = progress
    }
    
    
    func totalLoggedTime() -> Worktime {
        Worktime(totalMinutes: self.timeLogEntries.reduce(0) { $0 + Int($1.timeMinutes) })
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


//MARK: Sectioning

extension THTask {
    // The following computed vars are used to place tasks in different sections when fetching from core data.
    
    
    /// ISO8601 string of the year, month and day of the deadline
    /// Format: "[year]-[month]-[day]"
    /// - Note: Used for sectioning tasks by day.
    @objc var deadlineDayString: String {
        self.deadlineDate?.formatCalendarYearMonthDay() ?? "none"
    }
    
    /// The year and week of the deadline as a string.
    /// Format: "[year]-CW[week]"
    /// - Note: Used for sectioning tasks by calendar week.
    @objc var deadlineWeekString: String {
        self.deadlineDate?.formatCalendarYearWeek() ?? "none"
    }
    
    /// Cropped ISO8601 string of the year and month of the deadline
    /// Format: "[year]-[month]"
    /// - Note: Used for sectioning tasks by month.
    @objc var deadlineMonthString: String {
        self.deadlineDate?.formatCalendarYearMonth() ?? "none"
    }
    
    /// The year of the deadline as a string
    /// Format: "[year]"
    /// - Note: Used for sectioning tasks by year.
    @objc var deadlineYearString: String {
        self.deadlineDate?.formatCalendarYear() ?? "none"
    }
}
