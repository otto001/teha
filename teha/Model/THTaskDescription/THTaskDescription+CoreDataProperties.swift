//
//  THTaskDescription+CoreDataProperties.swift
//  teha
//
//  Created by Matteo Ludwig on 15.06.24.
//
//

import Foundation
import CoreData


extension THTaskDescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<THTaskDescription> {
        return NSFetchRequest<THTaskDescription>(entityName: "THTaskDescription")
    }
    
    @NSManaged public var project: THProject?
    @NSManaged public var tasks: Set<THTask>
    
    @NSManaged public var tags: Set<THTag>
    
    // MARK: Base
    @NSManaged public var title: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var earliestStartDate: Date?
    @NSManaged public var deadlineDate: Date?
    
    @NSManaged public private(set) var priorityNumber: Int16
    var priority: Priority {
        get {
            return Priority(rawValue: Int(self.priorityNumber)) ?? .normal
        }
        set {
            self.priorityNumber = Int16(newValue.rawValue)
        }
    }
    
    
    @NSManaged public private(set) var estimatedWorktimeMinutes: Int16
    /// The estimatedWorktime of the Task.
    var estimatedWorktime: Worktime? {
        get {
            guard estimatedWorktimeMinutes > 0 else { return nil }
            return Worktime(totalMinutes: Int(self.estimatedWorktimeMinutes))
        }
        set {
            if let newValue {
                self.estimatedWorktimeMinutes = Int16(newValue.totalMinutes)
            } else {
                self.estimatedWorktimeMinutes = 0
            }
        }
    }
    
    @NSManaged public var notes: String?

    
    // MARK: Location
    @NSManaged public var locationLatitude: Double
    @NSManaged public var locationLongitude: NSDecimalNumber?
    @NSManaged public var locationAddress: String?
    
    
    // MARK: Repeating
    @NSManaged public var repeatIntervalMinutes: Int32
    @NSManaged public var repeatEndDate: Date?
    @NSManaged public var repeatExceptionsString: String?
    
    var repeatInterval: RepeatInterval? {
        get {
            RepeatInterval(rawValue: Int(self.repeatIntervalMinutes))
        }
        set {
            self.repeatIntervalMinutes = (newValue?.rawValue).map { Int32($0) } ?? 0
        }
    }
    
    var isRepeatingTask: Bool {
        self.repeatIntervalMinutes > 0
    }
    
    /// The formatter used to save and read from the dataBase
    static let repeatExceptionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var repeatExceptions: Set<String> {
        get {
            Set(self.repeatExceptionsString?.split(separator: ";").map {String($0)} ?? [])
        }
        set {
            self.repeatExceptionsString = newValue.joined(separator: ";")
        }
    }

    /// Adds a date to the ignoredRepeatDates as a string
    func addRepeatException(date: Date) {
        self.repeatExceptions.insert(Self.repeatExceptionDateFormatter.string(from: date))
    }
    
    
    // MARK: Reminders
    
    @NSManaged private var reminderFirstMinutes: NSNumber?
    @NSManaged private var reminderSecondMinutes: NSNumber?
    
    /// The ReminderOffset to the tasks deadline of the first reminder of the Task
    var reminderFirstOffset: ReminderOffset? {
        get {
            self.reminderFirstMinutes.flatMap { ReminderOffset(rawValue: Int(truncating: $0)) }
        }
        set {
            self.reminderFirstMinutes = (newValue?.rawValue).map { NSNumber(value: $0) }
        }
    }
    
    /// The ReminderOffset to the tasks deadline of the second reminder of the Task
    var reminderSecondOffset: ReminderOffset? {
        get {
            self.reminderSecondMinutes.flatMap { ReminderOffset(rawValue: Int(truncating: $0)) }
        }
        set {
            self.reminderSecondMinutes = (newValue?.rawValue).map { NSNumber(value: $0) }
        }
    }

}


extension THTaskDescription : Identifiable {

}
