//
//  TimeChecking.swift
//  teha
//
//  Created by Andreas Romann and Matteo Ludwig on 17.01.23.
//

import Foundation
import SwiftUI

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int? {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day //TODO: do not force!
    }
}


fileprivate struct WrappedTask: Hashable {
    let task: THTask
    
    let earliestStartDate: Date?
    let deadline: Date

    let timeNeeded: Worktime
    
    init?(_ task: THTask) {
        guard let deadline = task.deadline else { return nil }
        
        // Ignore if task is completed or no estimatedWorktime was ever set
        guard task.estimatedWorktimeRemaining != .zero else { return nil }

        self.task = task
        self.earliestStartDate = task.earliestStartDate
        self.deadline = deadline
        self.timeNeeded = task.estimatedWorktimeRemaining
    }
    
//    var timeInterval: TimeInterval {
//        deadline.timeIntervalSince(earliestStartDate)
//    }
    
    func isActive(between intervalStart: Date, and intervalEnd: Date) -> Bool {
        if let earliestStartDate = earliestStartDate {
            return deadline >= intervalStart && earliestStartDate < intervalEnd
        }
        return deadline >= intervalStart
    }
}


fileprivate struct Bin {
    var task: WrappedTask?
}

fileprivate struct Bins: Collection {
    typealias Key = Date
    typealias Index = Dictionary<Key, Bin>.Index
    typealias Element = Bin
    
    private var internalDict: [Key: Bin]
    var binsPerHour: Int
    
    init(binsPerHour: Int) {
        self.internalDict = [:]
        self.binsPerHour = binsPerHour
    }

    var startIndex: Dictionary<Key, Bin>.Index { internalDict.startIndex }

    var endIndex: Dictionary<Key, Bin>.Index { internalDict.endIndex }

    func index(after i: Dictionary<Key, Bin>.Index) -> Dictionary<Key, Bin>.Index {
        internalDict.index(after: i)
    }
    
    subscript(position: Dictionary<Key, Bin>.Index) -> Bin {
        internalDict[position].value
    }
    
//    subscript(date: Key) -> Bin {
//        var totalMinutesOfDay = 60 * Calendar.current.component(.hour, from: date) + Calendar.current.component(.minute, from: date)
//        totalMinutesOfDay = max(startOfWorkDay*60, min(endOfWorkDay*60, totalMinutesOfDay))
//
//        var binOfDay = totalMinutesOfDay/minutesPerBin
//
////        if position == .end {
////            binOfDay -= 1
////        }
//
//        var binDate = Calendar.current.startOfDay(for: date)
//        binDate = Calendar.current.date(byAdding: .minute, value: binOfDay * minutesPerBin, to: binDate)!
//
//        internalDict[date, default: Bin(date: date)]
//    }
}

actor TaskOrderRecommendationGenerator {
    typealias Minutes = Int
    typealias Hours = Int
    
    private var tasks: [WrappedTask] = []

    let start: Date
    let end: Date

    //TODO: add to settings
    let hoursPerDay: Worktime = .init(hours: 8, minutes: 0)
    let workdays = [2, 3, 4, 5, 6]
    let startOfWorkDay: Worktime = .init(hours: 8, minutes: 0)
    
    var endOfWorkDay: Worktime {
        startOfWorkDay + hoursPerDay
    }
    
    let binsPerHour: Int = 60/5
    
    var minutesPerBin: Minutes {
        60/binsPerHour
    }
    
    private var bins: [BinKey: Bin] = [:]
    //private var dateToBinMap: [Bin: Int] = [:]

    init(start: Date) {
        // We always calculate 2 weeks ahead, so set the end date to be 2 weeks after the start date
        let end = start + TimeInterval.week*2
    
        
        self.start = start
        self.end = end
    }
    
    // MARK: Helpers
    
    /// Whether the given day is a weekday on which the user performs work.
    /// - Parameter date: The date to check. The time value of this date will be ignored, only the weekday is relevant.
    /// - Returns: True when the user selected the weekday of the given date as a work day.
    private func isWorkDay(date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return workdays.contains(weekday)
    }
    
    
    // MARK: Fetch from CoreData
    
    /// Fetches all tasks fitting the timespan to check (see start and end fields).
    /// Populates the tasks array with all relevant tasks.
    /// - Returns: True on success, false on failure.
    private func fetchTasks() -> Bool {
        let request = THTask.all
        
        // Only fetch Tasks with a deadline within the timespan to check
        request.filter(deadlineAfter: start)
        request.filter(deadlineBeforeEquals: end)
        
        // It is VERY important for our sorting & checking algorithm that the tasks are ordered by deadline in ascending order!
        request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
        
        guard let tasks = try? PersistenceController.shared.container.viewContext.fetch(request) else {
            // If we could not fetch the tasks for some reason, return false for failure
            return false
        }
        
        
        self.tasks = tasks.compactMap {
            // Map the tasks to WrappedTask. If the WrappedTask init fails, it is because the task is not suitable for checking (e.g. does not have a estimatedWorkduration)
            // We will simply ignore such tasks.
            WrappedTask($0)
        }.filter {
            // Only keep tasks with their earliestStartDate and deadline intersecting the start and end of this calculation
            $0.isActive(between: start, and: end)
        }
        
        return true
    }
    
    // MARK: Allocate Bins for Task
    
    private func allocateBins(for task: WrappedTask) {

        
        let deadlineBinKey = self.binKey(before: task.deadline)
        
        let startBinKey: BinKey?
        if let earliestStartDate = task.earliestStartDate {
            startBinKey = self.binKey(afterOrAt: earliestStartDate)
            
            // TODO: This guard should be useless
            guard startBinKey! <= deadlineBinKey else { return }
        } else {
            startBinKey = nil
        }
        
        
        let binsNeeded = Int(task.timeNeeded.totalMinutes / minutesPerBin)

        var remainingBinsNeeded = binsNeeded
        

        let iterSequence = sequence(first: deadlineBinKey) { binKey in
            let next = self.binKey(before: binKey)
            if let startBinKey = startBinKey, next < startBinKey {
                return nil
            }
            return next
        }
        
        for binKey in iterSequence {
            guard remainingBinsNeeded > 0 else { break }
            if self.placeTaskInBinIfEmpty(task, binKey: binKey) {
                remainingBinsNeeded -= 1
            }
        }
        
        // TODO: What if remainingBinsNeeded > 0
        print()
    }

    
    struct BinKey: Hashable, Comparable, Strideable {
        let binsSince1970: Int
        
        init(binsSince1970: Int) {
            self.binsSince1970 = binsSince1970
        }
        
        init(timeIntervalSince1970: TimeInterval, minutesPerBin: Int) {
            self.binsSince1970 = Int(timeIntervalSince1970) / (60*minutesPerBin)
        }
        
        
        init(date: Date, minutesPerBin: Int) {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let hours = Calendar.current.component(.hour, from: date)
            var minutes = Calendar.current.component(.minute, from: date)
            
            minutes = (minutes / minutesPerBin) * minutesPerBin
            // Is this needed?
            let truncatedDate = Calendar.current.date(byAdding: .minute, value: minutes + hours * 60, to: startOfDay)!
            
            self.init(timeIntervalSince1970: truncatedDate.timeIntervalSince1970, minutesPerBin: minutesPerBin)
        }
        
        static func < (lhs: TaskOrderRecommendationGenerator.BinKey, rhs: TaskOrderRecommendationGenerator.BinKey) -> Bool {
            return lhs.binsSince1970 < rhs.binsSince1970
        }
        
        func advanced(by n: Int) -> BinKey {
            return BinKey(binsSince1970: self.binsSince1970 + n)
        }

        func distance(to other: BinKey) -> Int {
            return other.binsSince1970 - self.binsSince1970
        }
        
        func date(minutesPerBin: Int) -> Date {
            return Date(timeIntervalSince1970: TimeInterval(binsSince1970 * minutesPerBin * 60))
        }
        
        var prev: BinKey {
            return advanced(by: -1)
        }
        
        var next: BinKey {
            return advanced(by: 1)
        }
    }
    
    private func binKey(firstOfDay date: Date) -> BinKey {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let workBegin = Calendar.current.date(byAdding: .minute, value: startOfWorkDay.totalMinutes, to: startOfDay)!
        return BinKey(date: workBegin, minutesPerBin: minutesPerBin)
    }
    
    private func binKey(lastOfDay date: Date) -> BinKey {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let workEnd = Calendar.current.date(byAdding: .minute, value: endOfWorkDay.totalMinutes, to: startOfDay)!
        return BinKey(date: workEnd, minutesPerBin: minutesPerBin).prev
    }
    
    private func isWorktime(binKey: BinKey) -> Bool {
        let date = binKey.date(minutesPerBin: minutesPerBin)
        
        guard isWorkDay(date: date) else { return false }
        
        let firstOfDay = self.binKey(firstOfDay: date)
        let lastOfDay = self.binKey(lastOfDay: date)
        
        return binKey >= firstOfDay && binKey <= lastOfDay
    }
    
    private func binKey(before binKey: BinKey) -> BinKey {
        var result = binKey
        repeat {
            result = result.prev
        } while !isWorktime(binKey: result)
        
        return result
    }
    
    private func binKey(before date: Date) -> BinKey {
        // return the bin at or the closes before date
        
        return self.binKey(before: BinKey(date: date, minutesPerBin: minutesPerBin))
    }
    
    private func binKey(afterOrAt date: Date) -> BinKey {
        // return the bin at or the closes after date
        
        var result = BinKey(date: date, minutesPerBin: minutesPerBin)
        while !isWorktime(binKey: result) {
            result = result.next
        }
        return result
        
    }
    


    private func placeTaskInBinIfEmpty(_ task: WrappedTask, binKey: BinKey) -> Bool {
        if self.bins[binKey]?.task == nil {
            self.bins[binKey, default: Bin()].task = task
            return true
        }
        return false
    }
    
    
    // MARK: Calculate
    
    func calculate() -> Result? {
        // Fetch tasks and make bins: If one of them fails for whatever reason, we cannot recover, so abort.
        guard self.fetchTasks() else {
            return nil
        }

        for task in tasks {
            self.allocateBins(for: task)
        }
        
        let sortedBinKeys = self.bins.keys.sorted()
        
        
        
        //let firstKey = BinKey(date: start, minutesPerBin: minutesPerBin)
//        for key in self.bins.keys {
//            if key < firstKey {
//                isFeasable = false
//                break
//            }
//        }
        
        // Give tolerance of 1 Bin width, therfore .next
        let isFeasable = sortedBinKeys.first!.next.date(minutesPerBin: minutesPerBin) >= start
        
        var tasksOrder = [TaskWithLatestStartDate]()
        var tasksSet = Set<THTask>()
        
        
        for binKey in sortedBinKeys {
            if let task = self.bins[binKey]?.task?.task, !tasksSet.contains(task) {
                tasksOrder.append(.init(task: task, latestStartDate: binKey.date(minutesPerBin: minutesPerBin)))
                tasksSet.insert(task)
            }
        }
//        for bin in self.bins {
//            if let task = bin.task?.task, !tasksSet.contains(task) {
//                tasksOrder.append(.init(task: task, latestStartDate: bin.date))
//                tasksSet.insert(task)
//
//                if bin.date < start {
//                    isFeasable = false
//                }
//            }
//        }
        
        
        return Result(tasks: tasksOrder, isFeasible: isFeasable)
    }
}

extension TaskOrderRecommendationGenerator {
    struct TaskWithLatestStartDate: Identifiable {
        let task: THTask
        let latestStartDate: Date
        
        var id: THTask.ID {
            task.id
        }
    }
    
    struct Result {
        let tasks: [TaskWithLatestStartDate]
        let isFeasible: Bool
    }
}
