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
    
    static func == (lhs: WrappedTask, rhs: WrappedTask) -> Bool {
        return lhs.task.id == rhs.task.id
    }
}

fileprivate struct BinKey: Hashable, Comparable, Strideable {
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
        // TODO: Is this needed?
        let truncatedDate = Calendar.current.date(byAdding: .minute, value: minutes + hours * 60, to: startOfDay)!
        
        self.init(timeIntervalSince1970: truncatedDate.timeIntervalSince1970, minutesPerBin: minutesPerBin)
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
    
    // Convert to date
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


fileprivate struct Bin {
    let task: WrappedTask
    var positionIsFinal: Bool = false
}

enum TaskOrderRecommendationGeneratorError: LocalizedError {
    case badWorktimeSettings
    case noCalculateableTasks
    
    var errorDescription: String? {
        switch self {
        case .badWorktimeSettings:
            return String(localized: "suggestions-bad-worktime-settings")
        case .noCalculateableTasks:
            return String(localized: "suggestions-no-calculateable-tasks")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .badWorktimeSettings:
            return String(localized: "suggestions-bad-worktime-settings-recovery")
        case .noCalculateableTasks:
            return String(localized: "suggestions-no-calculateable-tasks-recovery")
        }
    }
}

actor TaskOrderRecommendationGenerator {
    typealias Minutes = Int
    typealias Hours = Int
    
    private var tasks: [WrappedTask] = []

    let start: Date
    let end: Date


    let workdays: [Int]
    let startOfWorkDay: Worktime
    var endOfWorkDay: Worktime
    
    let binsPerHour: Int = 60/5
    
    var minutesPerBin: Minutes {
        60/binsPerHour
    }
    
    private var bins: [BinKey: Bin] = [:]

    init(start: Date) {
        // We always calculate 2 weeks ahead, so set the end date to be 2 weeks after the start date
        let end = start + TimeInterval.week*2
    
        
        self.start = start
        self.end = end
        
        self.workdays = Set<Int>(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.workDays.rawValue) as? String ?? "")?.sorted() ?? []
        self.startOfWorkDay = Worktime(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.startOfWorkDay.rawValue) as? Int ?? 0)
        
        self.endOfWorkDay = Worktime(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.endOfWorkDay.rawValue) as? Int ?? 0)
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
        request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true), NSSortDescriptor(key: "priorityNumber", ascending: false)]
        
        
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
    
    // MARK: Move
    
    private func backtrack(path: inout [BinKey]) {
        guard let lastBinKey = path.last,
              let task = self.bins[lastBinKey]?.task else {
            return
        }
        
        while let lastBinKey = path.popLast(),
              self.bins[lastBinKey]?.task == task {
            self.bins[lastBinKey]!.positionIsFinal = true
            print("Backtracking: removing \(lastBinKey.date(minutesPerBin: minutesPerBin))")
            
        }
    }
    
    // ERROR: WHAT IF NEXT BIN IS FAR AWAY??
//    private func isMovable(binKey: BinKey) -> Bool {
//        guard let bin = self.bins[binKey] else { return true }
//        guard !bin.positionIsFinal else { return false }
//
//        if let earliestStartDate = bin.task.earliestStartDate {
//            let earliestStartBinKey = self.binKey(afterOrAt: earliestStartDate)
//            return binKey > earliestStartBinKey
//        }
//
//        return true
//    }
//
    //TODO: rename
    private func closestBinWithoutFinalPosition(before binKey: BinKey) -> BinKey {
        var iterBinKey = binKey.prev
        
        while self.bins[iterBinKey]?.positionIsFinal == true {
            iterBinKey = self.binKey(before: iterBinKey)
        }
        
        return iterBinKey
    }
    
    private func doesMoveViolateEarliestStartDate(from fromBinKey: BinKey, to toBinKey: BinKey) -> Bool {
        let fromBin = self.bins[fromBinKey]!
        
        if let earliestStartDate = fromBin.task.earliestStartDate {
            let earliestStartBinKey = self.binKey(afterOrAt: earliestStartDate)
            return toBinKey < earliestStartBinKey
        }
        
        return false
    }
    
    private func move(from fromBinKey: BinKey, to toBinKey: BinKey) {
        //assert(self.canBeMoved(from: fromBinKey, to: toBinKey))
        
        self.bins[toBinKey] = self.bins[fromBinKey]
        self.bins[fromBinKey] = nil
    }
    
    private func moveToLeft(binKey: BinKey) -> Bool {
        guard self.bins[binKey]?.positionIsFinal != true else { return false }
        
        var selectedToMove: [BinKey] = [binKey]
        
        while let iterBinKey = selectedToMove.last, self.bins[iterBinKey] != nil {
            
            let destination = self.closestBinWithoutFinalPosition(before: iterBinKey)

            guard !self.doesMoveViolateEarliestStartDate(from: iterBinKey, to: destination) else {
                self.backtrack(path: &selectedToMove)
                continue
            }

            selectedToMove.append(destination)
        }
        
        
        guard selectedToMove.count > 1 else {
            return false
        }
        assert(selectedToMove.first == binKey)
        
        let reversedSelectedToMove = Array(selectedToMove.reversed())
        

        for (i, fromBinKey) in reversedSelectedToMove.enumerated() {
            let toBinKey = i == 0 ? self.binKey(before: fromBinKey) : reversedSelectedToMove[i - 1]

            self.move(from: fromBinKey, to: toBinKey)
        }
        
        return true
    }
    
    private func moveToLeft(binKey: BinKey, distance: Int) -> Int {
        
        var iterBinKey = binKey
        for i in 0..<distance {
            if self.moveToLeft(binKey: iterBinKey) {
                iterBinKey = self.binKey(before: iterBinKey)
            } else {
                return i
            }
        }
        
        return distance
    }
    
    // MARK: Allocate Bins for Task
    
    private func allocateBins(for task: WrappedTask) {

        
        let deadlineBinKey = self.binKey(before: task.deadline)
        
//        let startBinKey: BinKey?
//        if let earliestStartDate = task.earliestStartDate {
//            startBinKey = self.binKey(afterOrAt: earliestStartDate)
//
//            // TODO: This guard should be useless
//            guard startBinKey! <= deadlineBinKey else { return }
//        } else {
//            startBinKey = nil
//        }
        
        
        let binsNeeded = Int(task.timeNeeded.totalMinutes / minutesPerBin)

        var remainingBinsNeeded = binsNeeded
        

        let iterSequence = sequence(first: deadlineBinKey) { binKey in
            let next = self.binKey(before: binKey)
//            if let startBinKey = startBinKey, next < startBinKey {
//                return nil
//            }
            // TODO: is it okay to ignore earliestStartDate here? may screw up scheduling of other tasks
            return next
        }
        
        for binKey in iterSequence {
            guard remainingBinsNeeded > 0 else { break }
            
            if self.placeTaskInBinIfEmpty(task, binKey: binKey) {
                print("Placed \(task.task.title!) in \(binKey.date(minutesPerBin: minutesPerBin))")
                remainingBinsNeeded -= 1
            } else if self.moveToLeft(binKey: binKey) {
                
                let success = self.placeTaskInBinIfEmpty(task, binKey: binKey)
                assert(success)
                
                print("Moved \(binKey.date(minutesPerBin: minutesPerBin)) one step to left")
                print("Placed \(task.task.title!) in \(binKey.date(minutesPerBin: minutesPerBin))")
                remainingBinsNeeded -= 1
            }
        }
        
        // TODO: What if remainingBinsNeeded > 0 (cannot happend anymore)
        print()
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
        return self.binKey(before: BinKey(date: date, minutesPerBin: minutesPerBin))
    }
    
    private func binKey(afterOrAt binKey: BinKey) -> BinKey {
        // return the bin at or the closes after date
        
        var result = binKey
        while !isWorktime(binKey: result) {
            result = result.next
        }
        return result
    }
    
    private func binKey(afterOrAt date: Date) -> BinKey {
        return self.binKey(afterOrAt: BinKey(date: date, minutesPerBin: minutesPerBin))
    }
    


    private func placeTaskInBinIfEmpty(_ task: WrappedTask, binKey: BinKey) -> Bool {
        if self.bins[binKey] == nil {
            self.bins[binKey] = Bin(task: task)
            return true
        }
        return false
    }
    
    private func binIsEmpty(binKey: BinKey) -> Bool {
        return self.bins[binKey] == nil
    }
    
    
    // MARK: Calculate
    
    func calculate() throws -> Result {
        guard !self.workdays.isEmpty && self.startOfWorkDay < self.endOfWorkDay else {
            throw TaskOrderRecommendationGeneratorError.badWorktimeSettings
        }
        
        // Fetch tasks and make bins: If one of them fails for whatever reason, we cannot recover, so abort.
        guard self.fetchTasks(), !tasks.isEmpty else {
            throw TaskOrderRecommendationGeneratorError.noCalculateableTasks
        }

        print("\n\nSTART ALLOCATE")

        for task in tasks {
            print("\nALLOCATING FOR \(task.task.title!)")
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
            if let task = self.bins[binKey]?.task.task, !tasksSet.contains(task) {
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
