//
//  SuggestionsGenerator+Structs.swift
//  teha
//
//  Created by Matteo Ludwig on 28.01.23.
//

import Foundation


extension SuggestionsGenerator {
    
    
    /// A wrapper class around THTask that unwraps the tasks deadline and remainingEsitmatedWorktime so that we only have to doe that once.
    /// Using a class instead of a struct reduced runtime by more than 90% because we avoid a metric ton of copy operations within dicts.
    class UnwrappedTask: Hashable {
        let task: THTask
        
        let earliestStartDate: Date?
        let deadline: Date

        let remainingEsitmatedWorktime: Worktime
        
        /// Init only succeeds if the task has a deadline set and more than 0 worktime remaining.
        init?(_ task: THTask) {
            guard let deadline = task.deadline else { return nil }
            
            // Ignore if task is completed or no estimatedWorktime was ever set
            guard task.estimatedWorktimeRemaining != .zero else { return nil }

            self.task = task
            self.earliestStartDate = task.earliestStartDate
            self.deadline = deadline
            self.remainingEsitmatedWorktime = task.estimatedWorktimeRemaining
        }
        
        // Equatable Implementation
        static func == (lhs: UnwrappedTask, rhs: UnwrappedTask) -> Bool {
            return lhs.task.id == rhs.task.id
        }
        
        // Hasable Implementation
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.task.id)
        }
    }

    /// The struct used as a Dictionary Key for Bins.
    /// Represents a moment in time, but always rounded to the resolution of the used bin size (minutesPerBin).
    struct BinKey: Hashable, Comparable, Strideable {
        /// This is the number of minutesPerBin-many minutes that passed since the 1970 reference date.
        /// Example: If minutesPerBin is 5, 15 Minutes after the reference date would be represented by binsSince1970=3
        let binsSince1970: Int
        
        init(binsSince1970: Int) {
            self.binsSince1970 = binsSince1970
        }
        
        /// Init with TimeInterval
        init(timeIntervalSince1970: TimeInterval) {
            self.binsSince1970 = Int(timeIntervalSince1970) / (60*minutesPerBin)
        }
        
        /// Init with Date
        init(date: Date) {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        }
        
        // Comparable Implementation
        static func < (lhs: BinKey, rhs: BinKey) -> Bool {
            return lhs.binsSince1970 < rhs.binsSince1970
        }
        
        // Strideable Implementation
        func advanced(by n: Int) -> BinKey {
            return BinKey(binsSince1970: self.binsSince1970 + n)
        }

        func distance(to other: BinKey) -> Int {
            return other.binsSince1970 - self.binsSince1970
        }
        
        /// Convert back to Date
        var date: Date {
            return Date(timeIntervalSince1970: TimeInterval(binsSince1970 * minutesPerBin * 60))
        }
        
        /// Convert back to TimeInterval
        var timeIntervalSince1970: TimeInterval {
            return TimeInterval(binsSince1970 * minutesPerBin * 60)
        }
        
        /// The BinKey directly before self (minutesPerBin earlier)
        var prev: BinKey {
            return advanced(by: -1)
        }
        
        /// The BinKey directly after self (minutesPerBin later)
        var next: BinKey {
            return advanced(by: 1)
        }
    }

    /// The struct to be placed in a Dictionary using a BinKey as its key.
    /// The bin itself must be a struct, not a class.
    /// This is to ensure we can safely copy Bins without creating a mess of references.
    struct Bin: Equatable {
        /// The task the bin was allocated for
        let task: UnwrappedTask
        
        /// True if we are absolutetly certain that we cannot move this bin anymore to the left (earlier in time), without violating time constrainst.
        /// Since there is no reason to move a bin to the right (later in time), the position can be described as final in that case.
        /// - Note: Even if moving this bin in any way would violate time contraints, positionIsFinal may still be false!
        ///         Therefore, if positionIsFinal is false, that is no guarantee that the bin can be moved.
        ///         However, if positionIsFinal is true, we know the bin cannot be moved.
        var positionIsFinal: Bool = false
        
        init(task: UnwrappedTask, positionIsFinal: Bool = false) {
            self.task = task
            self.positionIsFinal = positionIsFinal
        }
        
        static func == (lhs: SuggestionsGenerator.Bin, rhs: SuggestionsGenerator.Bin) -> Bool {
            return lhs.positionIsFinal == rhs.positionIsFinal && lhs.task == rhs.task
        }
    }
}
