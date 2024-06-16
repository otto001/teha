//
//  THTaskDescription+CoreDataClass.swift
//  teha
//
//  Created by Matteo Ludwig on 15.06.24.
//
//

import Foundation
import CoreData

@objc(THTaskDescription)
public class THTaskDescription: NSManagedObject {

}

extension THTaskDescription {
    func updateTasks() {
        //let startingAt = startingAt ?? .distantPast.addingTimeInterval(1)
        
        // Get the oldDeadline, deadline, repeatInterval and repeatEndDate of the current THTask
        guard let managedObjectContext = self.managedObjectContext,
              let deadlineDate = self.deadlineDate,
              let timeshiftStep = self.repeatInterval?.timeInterval,
              let repeatEndDate = self.repeatEndDate else { 
            
            if tasks.count == 1 {
                self.tasks.first!.updateFromDescription(offset: 0)
            } else {
                // FIXME: Fix this
                fatalError("Fix this case pleas")
            }
            
            return
        }
        
        var repeatExceptions: Set<String> = self.repeatExceptions

        // variable that are all siblings, where the deadline is higher than the old deadline
        var siblingsToAdopt = self.tasks.filter {
            if $0.isStarted {
                repeatExceptions.insert(Self.repeatExceptionDateFormatter.string(from: $0.deadlineDate!))
                return false
            }
            return true
        }.sorted { a, b in
            (a.deadlineDate ?? .distantPast) > (b.deadlineDate ?? .distantPast)
        }

        // variable to get the start of the next day after the repeatEndDate
        let repeatEndDateStartOfNextDay = Calendar.current.startOfDay(for: repeatEndDate) + TimeInterval.day

        // a sequence from the current deadline + timeshiftStep to a date < repeatEndDateStartOfNextDay in the step size of timeshiftStep
        let dateSequence = sequence(first: deadlineDate) { current in
            let next = current + timeshiftStep
            return next < repeatEndDateStartOfNextDay ? next : nil
        }

        /// for every date in the sequence update the siblings or add new ones if there are no more
        for siblingDeadline in dateSequence {
            // ignore all dates where the date is in ignoredRepeatDates
            guard !repeatExceptions.contains(Self.repeatExceptionDateFormatter.string(from: siblingDeadline)) else { continue }

            if let task = siblingsToAdopt.popLast() {
                // update the sibling by the timeshift
                task.updateFromDescription(offset: siblingDeadline.timeIntervalSince(deadlineDate))
            } else {
                // if the siblingsToAdopt is empty, make a new repeatingChild with the current THTask as parent
                let task = THTask(context: managedObjectContext)
                task.taskDescription = self
                task.creationDate = .now
                task.updateFromDescription(offset: siblingDeadline.timeIntervalSince(deadlineDate))
            }
        }

        //if there are siblings left in siblingsToAdopt, delete them as they are behind the needed deadline
        for superfluousChild in siblingsToAdopt {
            if !superfluousChild.isStarted {
                managedObjectContext.delete(superfluousChild)
            }
        }
    }
}
