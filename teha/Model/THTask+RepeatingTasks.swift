//
//  THTask+Repeating.swift
//  teha
//
//  Created by Matteo Ludwig on 29.01.23.
//

import Foundation
import CoreData


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
    
    fileprivate var isRepeatingParent: Bool {
        return (self.repeatingChildren?.count ?? 0) > 0
    }
    
    fileprivate var isRepeatingChild: Bool {
        return self.repeatingParent != nil
    }
    
    var repeatingSiblings: Set<THTask>? {
        if self.isRepeatingParent {
            return self.repeatingChildren as? Set<THTask>
        } else if self.isRepeatingChild {
            var result = self.repeatingParent?.repeatingSiblings
            result?.remove(self)
            result?.insert(self.repeatingParent!)
            return result
        }
        return nil
    }
    
    func hasFutureSiblings() -> Bool {
        guard let deadline = self.deadline else { return false }
        guard let repeatingSiblings = self.repeatingSiblings else { return false }
        for repeatingSibling in repeatingSiblings {
            if let otherDeadline = repeatingSibling.deadline, otherDeadline > deadline {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func updateRepeatingChild(_ child: THTask, timeshift: TimeInterval) {
        guard let deadline = self.deadline else { return }
        
        let ignoredProperties = Set<String>(["repeatingChildren", "repeatingParent"])
        for propertyName in self.entity.propertiesByName.keys {
            guard !ignoredProperties.contains(propertyName) else { continue }
            child.setValue(self.value(forKey: propertyName), forKey: propertyName)
        }
        
        self.addToRepeatingChildren(child)
        
        child.deadline = deadline + timeshift
        if let earliestStartDate = self.earliestStartDate {
            child.earliestStartDate = earliestStartDate + timeshift
        }
    }
    
    @discardableResult
    fileprivate func makeRepeatingChild(managedObjectContext: NSManagedObjectContext, timeshift: TimeInterval) -> THTask? {
        let child = THTask(context: managedObjectContext)
        self.updateRepeatingChild(child, timeshift: timeshift)
        child.creationDate = .now
        return child
    }
    
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate func getIgnoredRepeatDates() -> Set<String> {
        return Set((self.repeatIgnoredDates ?? "").split(separator: ";").map { String($0) })
//            //.compactMap { dateString in
//            print(Self.dateFormatter.date(from: String(dateString)))
//            return Self.dateFormatter.date(from: String(dateString))
//        })
    }
    
    fileprivate func setIgnoredRepeatDates(_ repeatIgnoredDates: Set<String>) {
        self.repeatIgnoredDates = String(repeatIgnoredDates.joined(separator: ";"))
    }
    
    fileprivate func addToIgnoredRepeatDates(date: Date) {
        var currentDates = self.getIgnoredRepeatDates()
        //let startOfDay = Calendar.current.startOfDay(for: date)
        currentDates.insert(Self.dateFormatter.string(from: date))
        self.setIgnoredRepeatDates(currentDates)
    }
    
    fileprivate func removeFromRepeatingChain() {
        
        if self.isRepeatingParent {
            let firstChild = self.repeatingSiblings!.filter { $0.deadline != nil }.max { a, b in
                return a.deadline! < b.deadline!
            }
            for child in self.repeatingSiblings! {
                guard child != firstChild else { continue }
                child.repeatingParent = firstChild
            }
            
            assert((self.repeatingSiblings?.count ?? 0) == 0)
        } else if let deadline = self.deadline {
            self.repeatingParent?.addToIgnoredRepeatDates(date: deadline)
        }
        
        // TODO: WHAT IF SELF IS PARENT?
        self.repeatingParent = nil
        self.repeatInterval = nil
        self.repeatEndDate = nil
    }
    
    @discardableResult
    func updateRepeating(managedObjectContext: NSManagedObjectContext?, oldDeadline: Date?, updateFutureChildren: Bool) -> Bool {

        
        // If we do not want to update other children, we are done here
        guard updateFutureChildren else {
            self.removeFromRepeatingChain()
            return true
        }
        
        // If we do want to update future children, we must have a deadline, a repeatEndDate and an repeatInterval
        guard let oldDeadline = oldDeadline ?? self.deadline,
              let deadline = self.deadline,
                let timeshiftStep = self.repeatInterval?.timeInterval,
                let repeatEndDate = self.repeatEndDate else { return false }
        
        // ... and also a managedObjectContext
        guard let managedObjectContext = managedObjectContext ?? self.managedObjectContext else {
            return false
        }
        
        
        //var rejectedSiblings: [THTask] = []
        var siblingsToAdopt: [THTask] = []
        
        // use map
        for sibling in (self.repeatingSiblings ?? []) {
            guard sibling != self else { continue }
            guard let siblingDeadline = sibling.deadline else { continue }
            if siblingDeadline < oldDeadline {
                //rejectedSiblings.append(sibling)
            } else {
                siblingsToAdopt.append(sibling)
            }
        }
        

        let oldParent = self.repeatingParent
        self.repeatingParent = nil
        

       
        siblingsToAdopt.sort { a, b in
            a.deadline! < b.deadline!
        }
        
        let ignoredRepeatDates = self.getIgnoredRepeatDates()
        
        let repeatEndDateStartOfNextDay = Calendar.current.startOfDay(for: repeatEndDate) + TimeInterval.day

        let sequence = sequence(first: deadline + timeshiftStep) { current in
            let next = current + timeshiftStep
            return next < repeatEndDateStartOfNextDay ? next : nil
        }

        for siblingDeadline in sequence {
            guard !ignoredRepeatDates.contains(Self.dateFormatter.string(from: siblingDeadline)) else { continue }
            
            if let siblingToAdopt = siblingsToAdopt.popLast() {
                self.updateRepeatingChild(siblingToAdopt, timeshift: siblingDeadline.timeIntervalSince(deadline))
            } else {
                self.makeRepeatingChild(managedObjectContext: managedObjectContext, timeshift: siblingDeadline.timeIntervalSince(deadline))
            }
        }
        
        for superfloursChild in siblingsToAdopt {
            managedObjectContext.delete(superfloursChild)
        }
        
        if let oldParent = oldParent {
            let lastChildOfParentDeadline = oldParent.repeatingSiblings?.compactMap { $0.deadline }.max()
            if let lastChildOfParentDeadline = lastChildOfParentDeadline {
                oldParent.repeatEndDate = lastChildOfParentDeadline
            } else {
                oldParent.removeFromRepeatingChain()
            }
        }
        
        return true
    }
    
}
