//
//  THTask+CoreDataProperties.swift
//  teha
//
//  Created by Matteo Ludwig on 15.06.24.
//
//

import Foundation
import CoreData
import SwiftDate

extension THTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<THTask> {
        return NSFetchRequest<THTask>(entityName: "THTask")
    }
    
    @NSManaged public var taskDescription: THTaskDescription?
    @NSManaged public var project: THProject?
    @NSManaged public var timeLogEntries: Set<THTimeLogEntry>
    
    
    // MARK: Dates
    @NSManaged public var creationDate: Date?
    @NSManaged public var earliestStartDate: Date?
    @NSManaged public var deadlineDate: Date?
    
    // MARK: Progress
    @NSManaged public var startDate: Date?
    @NSManaged public var completionDate: Date?
    @NSManaged public var completionProgress: Double

}

extension THTask : Identifiable {

}
