//
//  THProject+CoreDataProperties.swift
//  teha
//
//  Created by Matteo Ludwig on 15.06.24.
//
//

import Foundation
import CoreData


extension THProject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<THProject> {
        return NSFetchRequest<THProject>(entityName: "THProject")
    }

    @NSManaged public var colorCode: String?
    @NSManaged public var completed: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var deadlineDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var priorityNumber: Int16
    
    @NSManaged public var tasks: Set<THTask>
    @NSManaged public var taskDecriptions: Set<THTaskDescription>

}

// MARK: Generated accessors for tasks
extension THProject {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: THTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: THTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension THProject : Identifiable {

}
