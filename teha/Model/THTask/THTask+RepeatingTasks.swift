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
