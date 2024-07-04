//
//  THTimeLogEntry+CoreDataProperties.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//
//

import Foundation
import CoreData


extension THTimeLogEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<THTimeLogEntry> {
        return NSFetchRequest<THTimeLogEntry>(entityName: "THTimeLogEntry")
    }
    
    /// The date when the work was done
    /// - Note: Uses UTC time zone!
    @NSManaged public var date: Date?
        /// The date when the entry was created
    /// - Note: Uses UTC time zone!
    @NSManaged public var creationDate: Date?
    @NSManaged public var timeMinutes: Int32
    @NSManaged public var notes: String?
    @NSManaged public var task: THTask?
    @NSManaged public var tags: Set<THTag>

    
    var worktime: Worktime {
        get { Worktime(totalMinutes: Int(self.timeMinutes)) }
        set { self.timeMinutes = Int32(newValue.totalMinutes) }
    }
}


extension THTimeLogEntry {
    /// Cropped ISO8601 string of the year and month of the deadline
    /// Format: "[year]-[month]"
    /// - Note: Used for sectioning log entries by month.
    @objc var monthString: String {
        guard let date = self.date else { return "none" }
        return String(date.ISO8601Format(.iso8601Date(timeZone: .current)).substring(start: 0, end: 7))
    }
}

extension THTimeLogEntry : Identifiable {

}
