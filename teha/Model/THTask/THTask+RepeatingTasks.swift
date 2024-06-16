//
//  THTask+Repeating.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import Foundation
import CoreData


extension THTask {
    func futureRepeats() -> [THTask] {
        guard let siblings = self.taskDescription?.tasks, let deadlineDate = self.deadlineDate else {
            return []
        }
        return siblings.filter { ($0.deadlineDate ?? .distantPast) > deadlineDate }
    }
    
    func hasFutureRepeats() -> Bool {
        guard let siblings = self.taskDescription?.tasks, let deadlineDate = self.deadlineDate else { return false }
        return siblings.first { ($0.deadlineDate ?? .distantPast) > deadlineDate } != nil
    }
    
    func hasPastRepeats() -> Bool {
        guard let siblings = self.taskDescription?.tasks, let deadlineDate = self.deadlineDate else { return false }
        return siblings.first { ($0.deadlineDate ?? .distantFuture) < deadlineDate } != nil
    }
    
    func deleteFutureRepeats() {
        guard let managedObjectContext = self.managedObjectContext else { return }
        for sibling in self.futureRepeats() {
            managedObjectContext.delete(sibling)
        }
    }
}
//
//// MARK: Repeating
///// An extension to the existing THTask struct to support repeating tasks
//extension THTask {
//
//    // The variable with its get and set methods for the repeating interval in hours. Currently daily or weekly
//    var repeatInterval: RepeatInterval? {
//        get {
//            guard self.repeatIntervalId != 0 else { return nil }
//            return RepeatInterval(rawValue: Int(self.repeatIntervalId))
//        }
//        set {
//            self.repeatIntervalId = Int32(newValue?.rawValue ?? 0)
//        }
//    }
//
//    // variable if the Task is marked as repeating
//    var isRepeating: Bool {
//        self.repeatInterval != nil
//    }
//
//    // variable if the current THTask is a parent in the repeating structure
//    fileprivate var isRepeatingParent: Bool {
//        return (self.repeatingChildren?.count ?? 0) > 0
//    }
//
//    // variable if the current THTask is a child in the repeating structure
//    fileprivate var isRepeatingChild: Bool {
//        return self.repeatingParent != nil
//    }
//
//    // variable with a set of THTasks that are siblings of the current THTask
//    var repeatingSiblings: Set<THTask>? {
//        // if the current THTask is a parent, return all children of the task as siblings
//        if self.isRepeatingParent {
//            return self.repeatingChildren as? Set<THTask>
//        // if the current THTask is a child , return all children of the parent Task, without the current Task and with the parent Task added
//        } else if self.isRepeatingChild {
//            var result = self.repeatingParent?.repeatingSiblings
//            result?.remove(self)
//            result?.insert(self.repeatingParent!)
//            return result
//        }
//        return nil
//    }
//
//    /// returns all Siblings with a deadline that is higher than the current task
//    func repeatingSiblings(after date: Date) -> Set<THTask>? {
//        self.repeatingSiblings?.filter { sibling in
//            guard let siblingDeadline = sibling.deadline else { return false }
//            return siblingDeadline > date
//        }
//    }
//
//    /// Return true if there are siblings with a deadline that is higher than the current task, else returns false
//    func hasFutureSiblings() -> Bool {
//        guard let deadline = self.deadline else { return false }
//        return !(self.repeatingSiblings(after: deadline)?.isEmpty ?? true)
//    }
//
//    ///
//    fileprivate func updateRepeatingChild(_ child: THTask, timeshift: TimeInterval) {
//        guard let deadline = self.deadline else { return }
//        
//        let ignoredProperties = Set<String>(["repeatingChildren", "repeatingParent"])
//        // Copy all properties of parent(self) to child, except repeatingChildren and repeatingParent
//        // else the complete parent to children chain would break
//        for propertyName in self.entity.propertiesByName.keys {
//            guard !ignoredProperties.contains(propertyName) else { continue }
//            child.setValue(self.value(forKey: propertyName), forKey: propertyName)
//        }
//
//        // add the child to the repeatingChildren of the parent(self)
//        self.addToRepeatingChildren(child)
//
//        // update the deadline of the child with the timeshift added
//        child.deadline = deadline + timeshift
//        // if there exists an earliestStartDate, also update the earliestStartDate by the timeshift
//        if let earliestStartDate = self.earliestStartDate {
//            child.earliestStartDate = earliestStartDate + timeshift
//        }
//    }
//
//    /// make an existing THTask to a children of the current task(self)
//    @discardableResult
//    fileprivate func makeRepeatingChild(managedObjectContext: NSManagedObjectContext, timeshift: TimeInterval) -> THTask? {
//        let child = THTask(context: managedObjectContext)
//        // update the deadline and if existing the earliestStartDate
//        self.updateRepeatingChild(child, timeshift: timeshift)
//        // Set the creationDate to .now
//        child.creationDate = .now
//        return child
//    }
//
//    /// The formatter used to save and read from the dataBase
//    fileprivate static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter
//    }()
//
//    /// Returns all ignoredRepeatDates as a set of Strings
//    fileprivate func getIgnoredRepeatDates() -> Set<String> {
//    // because we cannot store arrays of Dates in CoreData, we have to save and read them as a set of strings
//        return Set((self.repeatIgnoredDates ?? "").split(separator: ";").map { String($0) })
//    }
//
//    /// Sets the given set of string as the ignoredRepeatDates
//    fileprivate func setIgnoredRepeatDates(_ repeatIgnoredDates: Set<String>) {
//    // because we cannot store arrays of Dates in CoreData, we have to save and read them as a set of strings
//        self.repeatIgnoredDates = String(repeatIgnoredDates.joined(separator: ";"))
//    }
//
//    /// Adds a date to the ignoredRepeatDates as a string
//    fileprivate func addToIgnoredRepeatDates(date: Date) {
//        var currentDates = self.getIgnoredRepeatDates()
//        // Turn the date into a string using the DateFormatter
//        currentDates.insert(Self.dateFormatter.string(from: date))
//        self.setIgnoredRepeatDates(currentDates)
//    }
//
//    // Removes the current THTask from the repeating Chain
//    func removeFromRepeatingChain() {
//        
//        if self.isRepeatingParent {
//            // Get the child with the lowest deadline as the first child
//            let firstChild = self.repeatingSiblings!.filter { $0.deadline != nil }.min { a, b in
//                return a.deadline! < b.deadline!
//            }!
//            // For all children except the firstChild set the repeatingParent to the firstChild
//            for child in self.repeatingSiblings! {
//                guard child != firstChild else { continue }
//                child.repeatingParent = firstChild
//            }
//            // remove the parent of the firstChild
//            firstChild.repeatingParent = nil
//            // assert that all the children were removed
//            assert((self.repeatingSiblings?.count ?? 0) == 0)
//        } else if self.isRepeatingChild, let deadline = self.deadline {
//            // else if the current THTask is a child add the child to the ignoredRepeatDates of the parent
//            self.repeatingParent?.addToIgnoredRepeatDates(date: deadline)
//        }
//        // remove all not needed properties of the current task
//        self.repeatingParent = nil
//        self.repeatInterval = nil
//        self.repeatEndDate = nil
//    }
//
//    /// Updates the current context of the current THTask
//    /// - Parameter context: The used managedObjectContext
//    /// - Parameter oldDeadline: The old deadline of the current THTask
//    /// - Parameter updateFutureChildren: True if the updateRepeat should also update all future children, false if only for self
//    @discardableResult
//    func updateRepeat(context managedObjectContext: NSManagedObjectContext, oldDeadline: Date?, updateFutureChildren: Bool) -> Bool {
//
//        
//        // When the updateFutureChildren is False only self is removed from the repeating chain
//        guard updateFutureChildren else {
//            self.removeFromRepeatingChain()
//            return true
//        }
//        
//        // Get the oldDeadline, deadline, repeatInterval and repeatEndDate of the current THTask
//        guard let oldDeadline = oldDeadline ?? self.deadline,
//              let deadline = self.deadline,
//                let timeshiftStep = self.repeatInterval?.timeInterval,
//                let repeatEndDate = self.repeatEndDate else { return false }
//
//        // variable that are all siblings, where the deadline is higher than the old deadline
//        var siblingsToAdopt = (self.repeatingSiblings(after: oldDeadline) ?? []).sorted { a, b in
//            a.deadline! < b.deadline!
//        }
//
//        // set the oldparent as the repeatingParent and set repeatingParent to nil
//        let oldParent = self.repeatingParent
//        self.repeatingParent = nil
//
//        if let oldParent = oldParent {
//            // copy the ignored dates from the old parent (if there is one)
//            self.setIgnoredRepeatDates(oldParent.getIgnoredRepeatDates())
//        }
//        
//        // read the ignoredRepeatDates
//        let ignoredRepeatDates = self.getIgnoredRepeatDates()
//        // variable to get the start of the next day after the repeatEndDate
//        let repeatEndDateStartOfNextDay = Calendar.current.startOfDay(for: repeatEndDate) + TimeInterval.day
//
//        // a sequence from the current deadline + timeshiftStep to a date < repeatEndDateStartOfNextDay in the step size of timeshiftStep
//        let sequence = sequence(first: deadline + timeshiftStep) { current in
//            let next = current + timeshiftStep
//            return next < repeatEndDateStartOfNextDay ? next : nil
//        }
//
//        /// for every date in the sequence update the siblings or add new ones if there are no more
//        for siblingDeadline in sequence {
//            // ignore all dates where the date is in ignoredRepeatDates
//            guard !ignoredRepeatDates.contains(Self.dateFormatter.string(from: siblingDeadline)) else { continue }
//            
//            if let siblingToAdopt = siblingsToAdopt.popLast() {
//                // update the sibling by the timeshift
//                self.updateRepeatingChild(siblingToAdopt, timeshift: siblingDeadline.timeIntervalSince(deadline))
//            } else {
//                // if the siblingsToAdopt is empty, make a new repeatingChild with the current THTask as parent
//                self.makeRepeatingChild(managedObjectContext: managedObjectContext, timeshift: siblingDeadline.timeIntervalSince(deadline))
//            }
//        }
//
//        //if there are siblings left in siblingsToAdopt, delete them as they are behind the needed deadline
//        for superfluousChild in siblingsToAdopt {
//            managedObjectContext.delete(superfluousChild)
//        }
//
//
//        if let oldParent = oldParent, let oldParentDeadline = oldParent.deadline {
//            // get the deadline of the lat child of the oldparent
//            let lastChildOfParentDeadline = oldParent.repeatingSiblings?.compactMap { $0.deadline }.max()
//            // check that the oldparent ahs a child left
//            if let lastChildOfParentDeadline = lastChildOfParentDeadline {
//                // set the repeatEndDate of the oldparent as the lastChildOfParentDeadline
//                oldParent.repeatEndDate = lastChildOfParentDeadline
//                let oldParentRepeatEndDateString = Self.dateFormatter.string(for: oldParent.repeatEndDate!)!
//
//                // calculate the new ignoredRepeatDates for the oldparent
//                let oldParentNewIgnoredRepeatDates = oldParent.getIgnoredRepeatDates().filter { ignoredDate in
//                    ignoredDate <= oldParentRepeatEndDateString
//                }
//                // set the new ignoredRepeatDates for the oldparent
//                oldParent.setIgnoredRepeatDates(oldParentNewIgnoredRepeatDates)
//                
//                oldParent.updateRepeat(context: managedObjectContext, oldDeadline: oldParentDeadline, updateFutureChildren: true)
//            } else {
//                // if no last child exists remove the oldparent from the repeatingchain
//                oldParent.removeFromRepeatingChain()
//            }
//        }
//        
//        return true
//    }
//    
//    /// Deletes all future repeatingChildren of the current THTask
//    func deleteFutureRepeatSiblings(context: NSManagedObjectContext) {
//        guard let deadline = self.deadline else { return }
//        
//        // update the repeating chain then delete the children
//        self.updateRepeat(context: context, oldDeadline: deadline, updateFutureChildren: true)
//        for sibling in (self.repeatingSiblings(after: deadline) ?? .init()) {
//            context.delete(sibling)
//        }
//        
//        self.setIgnoredRepeatDates(.init())
//    }
//}
