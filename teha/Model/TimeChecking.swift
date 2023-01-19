//
//  TimeChecking.swift
//  teha
//
//  Created by Matteo Ludwig on 17.01.23.
//

import Foundation

//extension Array {
//
//    func divide(_ isInFirst: (_ element: Element) -> Bool) -> (Self, Self) {
//        var result1: Self
//        var result2: Self
//        for value in self {
//            if isInFirst(value) {
//                result1.append(value)
//            } else {
//                result2.append(value)
//            }
//        }
//        return (result1, result2)
//    }
//}

enum DateRangeCompare {
    case start, end
}

fileprivate struct WrappedTask: Hashable {
    let task: THTask
    let start: Date
    let end: Date
    let timeNeeded: TimeInterval
    
    init?(_ task: THTask) {
        guard let start = task.startDate,
              let end = task.deadline,
              let timeEstimate = task.timeEstimate else { return nil }
        self.task = task
        self.start = start
        self.end = end
        self.timeNeeded = 60*Double(truncating: timeEstimate)*(1-task.completionProgress)
    }
    
    var timeInterval: TimeInterval {
        end.timeIntervalSince(start)
    }
    
    func isActive(between intervalStart: Date, and intervalEnd: Date) -> Bool {
        return end >= intervalStart && start < intervalEnd
    }
}

fileprivate struct TimeSpan {
    var tasks: Set<WrappedTask>
    let start: Date
    let end: Date
    var workDuration: TimeInterval?
    
    init(tasks: Set<WrappedTask>, start: Date, end: Date) {
        self.tasks = tasks.filter {
            $0.isActive(between: start, and: end)
        }
        self.start = start
        self.end = end
        self.workDuration = nil
    }
    
    var timeInterval: TimeInterval {
        end.timeIntervalSince(start)
    }
    
    var feasible: Bool {
        return workDuration! <= timeInterval
    }
    
    mutating func approximateWorkDuration() {
        workDuration = 0
        for task in tasks {
            workDuration! += task.timeNeeded * (task.timeInterval/timeInterval)
        }
    }
    
    func includes(date: Date, mode: DateRangeCompare = .start) -> Bool {
        switch mode {
        case .start:
            return date >= start && date < end
        case .end:
            return date > start && date <= end
        }
        
    }
    
    mutating func add(_ task: WrappedTask) {
        guard task.isActive(between: start, and: end) else {
            print("AA")
            return
        }
        tasks.insert(task)
    }
}


fileprivate struct TimeLine {
    var timespans: [TimeSpan]
    
    mutating func index(including date: Date, mode: DateRangeCompare = .start) -> Int? {
        for (i, timespan) in timespans.enumerated() {
            if timespan.includes(date: date, mode: mode) {
                return i
            }
        }
        return nil
    }
    
    mutating private func splitTimespan(at splitDate: Date) {
        guard let index = index(including: splitDate) else { return }
        let timespan = timespans[index]
        
        let leftTimespan = TimeSpan(tasks: timespan.tasks, start: timespan.start, end: splitDate)
        let rightTimespan = TimeSpan(tasks: timespan.tasks, start: splitDate, end: timespan.end)
        
        timespans.remove(at: index)
        if !rightTimespan.tasks.isEmpty {
            timespans.insert(rightTimespan, at: index)
        }
        if !leftTimespan.tasks.isEmpty {
            timespans.insert(leftTimespan, at: index)
        }
    }
    
    mutating func add(task: THTask) {
        guard let task = WrappedTask(task) else { return }
        splitTimespan(at: task.start)
        splitTimespan(at: task.end)
        
        guard !timespans.isEmpty else {
            timespans.append(TimeSpan(tasks: [task], start: task.start, end: task.end))
            return
        }
        
        if task.start < timespans.first!.start {
            if task.end < timespans.first!.start {
                timespans.insert(TimeSpan(tasks: [task], start: task.start, end: task.end), at: 0)
                timespans.insert(TimeSpan(tasks: [], start: task.end, end: timespans.first!.start), at: 1)
            } else {
                timespans.insert(TimeSpan(tasks: [task], start: task.start, end: timespans.first!.start), at: 0)
            }
        }
        
        if task.end > timespans.last!.end {
            if task.start > timespans.last!.end {
                timespans.append(TimeSpan(tasks: [], start: timespans.last!.end, end: task.start))
                timespans.append(TimeSpan(tasks: [task], start: task.start, end: task.end))
            } else {
                timespans.append(TimeSpan(tasks: [task], start: timespans.last!.end, end: task.end))
            }
        }
        
        let startIndex = index(including: task.start, mode: .start)!
        let endIndex = index(including: task.end, mode: .end)!
        
        for index in startIndex...endIndex {
            timespans[index].add(task)
        }
    }
    
    mutating func isFeasible() -> Bool {
        for i in timespans.indices {
            timespans[i].approximateWorkDuration()
            if !timespans[i].feasible {
                print("NOOO")
            }
        }

        return true
    }
}

func checkValidity() -> Bool {
    
    let task1 = THTask(context: PersistenceController.preview.container.viewContext)
    task1.startDate = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 8).date!
    task1.deadline = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 20, minute: 0).date!
    task1.timeEstimate = NSDecimalNumber(value: 4*60)
    
    let task2 = THTask(context: PersistenceController.preview.container.viewContext)
    task2.startDate = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 8, minute: 0).date!
    task2.deadline = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 16, minute: 0).date!
    task2.timeEstimate = NSDecimalNumber(value: 8*60)
    
    let task3 = THTask(context: PersistenceController.preview.container.viewContext)
    task3.startDate = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 8, minute: 0).date!
    task3.deadline = DateComponents(calendar: .current, year: 2020, month: 1, day: 1, hour: 20, minute: 0).date!
    task3.timeEstimate = NSDecimalNumber(value: 2*60)
    
    var timeline = TimeLine(timespans: [])
    timeline.add(task: task1)
    timeline.add(task: task2)
    //timeline.add(task: task3)
    
    return timeline.isFeasible()
}

