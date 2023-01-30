//
//  TimeChecking.swift
//  teha
//
//  Created by Andreas Romann and Matteo Ludwig on 17.01.23.
//

import Foundation
import SwiftUI
import CoreData
import OSLog


class SuggestionsGenerator {
    // Logging and execution timing
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SuggestionsGenerator")
    let signposter = OSSignposter(logger: logger)
    
    private var tasks: [UnwrappedTask] = []

    /// Instead of using Date.now, which would change while the algorithm is running, we use a contstant now value which we set ounce upon creation of the generator.
    /// This also allows for better testing.
    var now: Date

    /// The ManagedObjectContext from which the generator fetches the tasks it processes. Default to the apps viewContext (PersistenceController.shared.container.viewContext)
    let managedObjectContext: NSManagedObjectContext

    /// The users settings of which weekdays they work and when they start and stop working each day
    let workdays: [Int] //TODO: Bug with Settings -> check for different locales/first day of week settings
    let startOfWorkDay: Worktime
    var endOfWorkDay: Worktime
    

    /// Sets the bin size to 5 minutes per bin, which is about as fine as time planning needs to be
    /// - Note: When adjusting this value, ensure it is a divisor of 60, as one hour must always be dividable into bins without rest.
    static let minutesPerBin: Int = 5
    
    /// The binning dictionary. Each bin represents a timeslot of \<minutesPerBin> minutes and is keyed with a BinKey.
    /// Each entry in this dict represents an assignment of a task to a bin/timeslot.
    private var bins: [BinKey: Bin] = [:]

    init(now: Date, managedObjectContext: NSManagedObjectContext? = nil) {
        self.now = now
        self.managedObjectContext = managedObjectContext ?? PersistenceController.shared.container.viewContext
        
        // Fetch the users settings from UserDefaults
        self.workdays = Set<Int>(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.workDays.rawValue) as? String ?? "")?.sorted() ?? []
        self.startOfWorkDay = Worktime(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.startOfWorkDay.rawValue) as? Int ?? 0)
        self.endOfWorkDay = Worktime(rawValue: UserDefaults.standard.value(forKey: SettingsAppStorageKey.endOfWorkDay.rawValue) as? Int ?? 0)
    }
    
    
    // MARK: Fetch from CoreData
    
    /// Fetches all tasks fitting the timespan to check (see start and end fields).
    /// Populates the tasks array with all relevant tasks.
    /// - Returns: True on success, false on failure.
    private func fetchTasks() -> Bool {
        let request = THTask.all
        
        // Only fetch Tasks with a deadline in the future
        request.filter(deadlineAfter: self.now)
        
        // We only support suggestions for up to 10 tasks as to not overwhelm the user.
        // Also, performance issues are a thing.
        request.fetchLimit = 10
        
        // It is VERY important for our sorting & checking algorithm that the tasks are ordered by deadline in ascending order!
        request.sortDescriptors = [NSSortDescriptor(key: "deadline_DO_NOT_USE", ascending: true), NSSortDescriptor(key: "priorityNumber", ascending: false)]
        
        var tasks: [THTask]?
        
        // Fetch on thread of context
        self.managedObjectContext.performAndWait {
            tasks = try? self.managedObjectContext.fetch(request)
        }
        
        guard let tasks = tasks else {
            // If we could not fetch the tasks for some reason, return false for failure
            return false
        }
        
        
        self.tasks = tasks.compactMap {
            // Map the tasks to UnwrappedTask. If the UnwrappedTask init fails, it is because the task is not suitable for checking (e.g. does not have a estimatedWorkduration)
            // We will simply ignore such tasks.
            UnwrappedTask($0)
        }
        
        return true
    }
    
    // MARK: Moving & Backtracking
    
    
    
    // MARK: backtrack
    
    /// Walks backwards along the given parh (starting with the last element and moving towards the first).
    /// Each visited bins gets its position marked as final.
    /// All visited binKeys of the path get removed from the path.
    /// Continues to walk backwards until the task of the visited bin does not equal the task that was placed in the first visited bin.
    /// - Parameter path: The path which to walk backwards. This function may remove one, some or all binKeys from the path.
    /// - Note: This functions is used in the implementation of moveToLeft(binKey:)
    private func backtrack(path: inout [BinKey]) {
        guard let lastBinKey = path.last,
              let task = self.bins[lastBinKey]?.task else {
            return
        }
        
        while let lastBinKey = path.popLast(),
              self.bins[lastBinKey]?.task == task {
            self.bins[lastBinKey]!.positionIsFinal = true
           
        }
    }
    
    // MARK: closestBinWithoutFinalPosition
    
    /// Returns the bin closest to the given binKey, which lays left of binKey (is smaller, thus earlier in time) and its bin is either empty or does not have its position marked as final.
    /// In most cases, the return of this method will be equal to binKey(leftOf:). However, if the bins before the given binKey have a final position, we will skip them.
    /// - Parameter binKey: The BinKey where to start looking.
    /// - Returns: The bin closest to the given binKey, which lays before binKey and its bin is either empty or does not have its position marked as final.
    ///     The result will be at least one smaller than the given binKey.
    /// - Note: This functions is used in the implementation of moveToLeft(binKey:)
    private func closestBinWithoutFinalPosition(leftOf binKey: BinKey) -> BinKey {
        // Start one binKey left of the given binKey
        var iterBinKey = binKey.prev
        
        // Walk "left" until we find a bin that is either empty or does not have its position marked as final
        while self.bins[iterBinKey]?.positionIsFinal == true {
            iterBinKey = self.binKey(leftOf: iterBinKey)
        }
        
        return iterBinKey
    }
    
    // MARK: canBePlacedInBin
    
    /// Whether the task can be placed in the biven bin without violating the earliestStartDate of the task.
    /// - Parameter task: Tash task that should be checked.
    /// - Parameter binKey: The binKey of the bin in which the task should be placed.
    /// - Returns: True if placing the task in the bin does not violate the tasks earliestStartDate.
    ///     If the task does not have an earliestStartDate set, true is returned as the is no constraint to violate.
    /// - Note: This functions is used in the implementation of moveToLeft(binKey:)
    private func canBePlacedInBin(task: UnwrappedTask, binKey: BinKey) -> Bool {
        
        if let earliestStartDate = task.earliestStartDate {
            // If the binKey lies left of the binkey of earliestStartBinKey, we are in violation of the time contraint imposed by the earliestStartDate and should return false
            return binKey.timeIntervalSince1970 >= earliestStartDate.timeIntervalSince1970
        }
        
        // No earliestStartDate -> no contraint -> no problem
        return true
    }
    
    
    // MARK: moveToLeft
    
    /// Attempts to empty the bin of the given binKey by moving the bin to the closest possible position left of its current one.
    /// By doing this, other bins left of the given bin may also be moved in order to make space for the moving bin.
    /// Bins may also "jump" over bins that cannot be moved in order to make space.
    /// However, the move is not executed if it would violate the earliestStartDate of any task of the bins that would be moved.
    /// - Parameter binKey: The key of the bin to move to the left.
    /// - Returns: True if the move could be executed and false if not. If false is returned, no bin was moved at all.
    ///     Also returns  true if the bin of the given binKey is empty. In that case, no bins are moved.
    private func moveToLeft(binKey binKeyToMove: BinKey) -> Bool {
        // Check that the bin we want to move is actually populated. If it is empty, we do not need to move it and can abort with success.
        guard let binToMove = self.bins[binKeyToMove] else { return true }
        
        // If the position of the bin to move is already final, there is nothing more we can do, so we abort and return false
        guard binToMove.positionIsFinal == false else { return false }
        
       
        // The bins affected by the move operation.
        // When starting, this already included the binKeyToMove.
        // In the while loop below, new BinKeys may be added if other bins have to move in order to make space for the bin we actually want to move.
        // Due to the nature of the while loop, the BinKeys in this array will always be sorted in descending order.
        // Therefore, the last element of the array will always be the earliest (i.e. left-most) binKey in terms of time.
        // CAREFUL: In the following, we will refer to the last binKey of this array as the "head", as it is the earliest binKey
        var selectedToMove: [BinKey] = [binKeyToMove]
        
        // As long as the head is at a position that is not empty, we need to continue walking to the left
        while let head = selectedToMove.last, let headBin = self.bins[head] {
            
            // Get the closest bin to the left that does not have its position final (and could therefore possibly be moved to make space)
            // If the bins left of us have their position as final, we "jump" over them.
            let destination = self.closestBinWithoutFinalPosition(leftOf: head)

            // Check that moving head to the potential destination does not violate the potential time contraint of a tasks earliest start date.
            // Since we are not allowed to start a task before its earliest start date, we backtrack in case of a violation.
            guard self.canBePlacedInBin(task: headBin.task, binKey: destination) else {
                // If we cannot move head to destination without violating the earliestStartDate, we know that the bin at head cannot be moved anymore.
                // Therefore, the bin at head has reached its final position.
                // Consequently, all bins in selectedToMove with the same task as head, which can be reached from head without a bin with another task assiged between them, also have reached their final position.
                // As a consequence, we have run into a dead-end, where we cannot move the current head but have to.
                // Therefore, our only option is to mark all of the now-in-final-position bins, and go back along the path of selectedToMove to the first bin that is not at its final position.
                // This is exactly what the backtrack method does.
                // From our new (previously visited) head, we will try again. Due to the bins now having their positionIsFinal flag set, we will have a different outcome.
                // It is also possible, that the very first element in selectedToMove will also be marked as having reached its final position. In that case, the backtrack function would completely clear our path, causing the move to fail.
                self.backtrack(path: &selectedToMove)
                continue
            }
            
            // If the move was allowed, we append the destination to our selectedToMove array, making destination the head for the next iteration
            selectedToMove.append(destination)
        }
        
        // selectedToMove should either be empty if the move failed, or contain at least two elements
        assert(selectedToMove.count != 1)
        
        guard !selectedToMove.isEmpty else {
            // If selectedToMove is empty, we cannot move anything and have failed
            return false
        }
        
        // The first element of selectedToMove should still be the binKeyToMove we want to move
        assert(selectedToMove.first == binKeyToMove)
        

        // We no go backwards through selectedToMove, moving each bin into its new position.
        // In the reversed selectedToMove, the binKeyToMove the function was called with is the last element.
        // The first element is an empty bin, which will be filled to make space for all other bins moves.
        let reversedSelectedToMove = Array(selectedToMove.reversed())
        for (i, fromBinKey) in reversedSelectedToMove[1...].enumerated() {
            // Here we want to move fromBinKey into its new position
            // This new position is its predecessor in the reversedSelectedToMove array
            // Note the missing "-1": this is no accident, since we skip the first value of the array
            let toBinKey = reversedSelectedToMove[i]
            
            // Only move if the bins are actually different
            // If the bins are equal, compying one to the other would be a waste of time
            // This check alone made the moveLeft function more than 40x faster!
            guard self.bins[fromBinKey] != self.bins[toBinKey] else { continue }
            
            // Perform move
            self.bins[toBinKey] = self.bins[fromBinKey]
        }
        
        // binKey is now free! finally...
        self.bins[binKeyToMove] = nil
        
        return true
    }
    
    
    // MARK: placeInBinIfEmpty
    
    /// Places the task in the bin of the given binKey if the bin is empty.
    /// - Parameter task: The task to place in the bin.
    /// - Parameter binKey: The BinKey of the bin where to place the task.
    /// - Returns: True if the bin was empty and is now filled with the task, false if it was already taken.
    private func placeInBinIfEmpty(task: UnwrappedTask, binKey: BinKey) -> Bool {
        if self.bins[binKey] == nil {
            self.bins[binKey] = Bin(task: task)
            return true
        }
        return false
    }
    

    // MARK: placeInBins
    
    /// Places the task in enough bins to cover the tasks remaining estimated worktime.
    /// May move other, already placed tasks into different bins to make space, ensuring to do so without breaking any time-constraints.
    /// - Parameter task: The task to place into bins.
    private func placeInBins(task: UnwrappedTask) {
        // Calculate how many bins we need to allocate for the task in order to distribute the time needed to complete
        var remainingBinsNeeded = Int(task.remainingEsitmatedWorktime.totalMinutes / Self.minutesPerBin)
        
        // Define sequence that stats at deadline and then simply moves left step by step
        let iterSequence = sequence(first: self.binKey(leftOf: task.deadline)) { binKey in
            return self.binKey(leftOf: binKey)
        }
        
        // Now move left until we filled enough bins
        for binKey in iterSequence {
            // If the entire worktime of the task was distributed, we can stop
            guard remainingBinsNeeded > 0 else { break }
            
            
            if self.placeInBinIfEmpty(task: task, binKey: binKey) {
                // Bin was empty, so we simply placed task in the bin.
                remainingBinsNeeded -= 1
            } else if self.moveToLeft(binKey: binKey) {
                // Bin was not empty, but we were able to move the contents of the bin one to the left.
                // Therefore, the bin is now ours and we place the task in it.
                self.bins[binKey] = Bin(task: task)
                remainingBinsNeeded -= 1
            }
        }
    }

    
    
    // MARK: Helpers
    
    /// Whether the given day is a weekday on which the user performs work.
    /// - Parameter date: The date to check. The time value of this date will be ignored, only the weekday is relevant.
    /// - Returns: True when the user selected the weekday of the given date as a work day.
    private func isWorkDay(date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return workdays.contains(weekday)
    }
    
    /// Returns the BinKey for the day of the date at the time of the users start of workday. Does not check that the given day is a workday.
    /// - Parameter date: The date of the day for which to get the first BinKey.
    /// - Returns: The first BinKey of the day.
    private func binKey(firstOfDay date: Date) -> BinKey {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let workBegin = Calendar.current.date(byAdding: .minute, value: startOfWorkDay.totalMinutes, to: startOfDay)!
        return BinKey(date: workBegin)
    }
    
    /// Returns the BinKey for the day of the date at the time of the users end of workday. Does not check that the given day is a workday.
    /// - Parameter date: The date of the day for which to get the last BinKey.
    /// - Returns: The last BinKey of the day.
    private func binKey(lastOfDay date: Date) -> BinKey {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let workEnd = Calendar.current.date(byAdding: .minute, value: endOfWorkDay.totalMinutes, to: startOfDay)!
        return BinKey(date: workEnd).prev
    }
    
    /// Returns whether the given BinKey liest within the users selected worktime.
    /// - Parameter binKey: The BinKey to check.
    /// - Returns: True when the given BinKey liest within the users selected worktime, false otherwise.
    private func isWorktime(binKey: BinKey) -> Bool {
        let date = binKey.date
        
        guard isWorkDay(date: date) else { return false }
        
        let firstOfDay = self.binKey(firstOfDay: date)
        let lastOfDay = self.binKey(lastOfDay: date)
        
        return binKey >= firstOfDay && binKey <= lastOfDay
    }
    
    /// The closest BinKey to the left (i.e., earlier in time) of the given BinKey that lies within the users worktime. Always returns a smaller BinKey than the given one.
    /// - Parameter binKey: The BinKey at which to start.
    /// - Returns: A BinKey that is left of (i.e., before) the given one and also lies withitn the users worktime.
    private func binKey(leftOf binKey: BinKey) -> BinKey {
        var result = binKey.prev
        
        repeat {
            result = result.prev
        } while !isWorktime(binKey: result)
        
        return result
    }
    
    /// The BinKey closest to the given Date that lies within the users worktime. Always returns a smaller BinKey than the given one.
    /// - Parameter date: The Date at which to start.
    /// - Returns: A BinKey that is smaller (i.e., before) the given Date and also lies withitn the users worktime.
    private func binKey(leftOf date: Date) -> BinKey {
        return self.binKey(leftOf: BinKey(date: date))
    }
    
    /// The closest BinKey to the right (i.e., later in time) of the given BinKey that lies within the users worktime. If the given BinKey already lies within the users worktime, the given binKey is returned.
    /// - Parameter binKey: The BinKey at which to start.
    /// - Returns: A BinKey that is the same or right of (i.e. at or later in time) the given one and also lies withitn the users worktime.
    private func binKey(rightOfOrAt binKey: BinKey) -> BinKey {
        var result = binKey
        while !isWorktime(binKey: result) {
            result = result.next
        }
        return result
    }
    
    /// The closest BinKey to the right (i.e., later in time) of the given Date that lies within the users worktime. If the given Date already lies within the users worktime, the BinKey of that Date is returned.
    /// - Parameter date: The Date at which to start.
    /// - Returns: A BinKey that is at or right of (i.e. at or later in time) the given Date and also lies withitn the users worktime.
    private func binKey(rightOfOrAt date: Date) -> BinKey {
        return self.binKey(rightOfOrAt: BinKey(date: date))
    }
    

    // MARK: Calculate
    
    /// Calculates and returns Suggestions on which tasks to start when for the user.
    /// - Returns: A SuggestionsGenerator.Result containing the suggestions for the user on success.
    /// - Throws: Errors of type SuggestionsGeneratorError and CancellationError.
    func calculate() async throws -> Result {
        
        // If user works 0 days a week or starts working after he stops working, we have a case of misconfiguration by the user
        guard !self.workdays.isEmpty && self.startOfWorkDay < self.endOfWorkDay else {
            throw SuggestionsGeneratorError.badWorktimeSettings
        }

        // Regularly check if calculate was cancelled
        try Task.checkCancellation()
        
        // Fetch tasks and make bins: If one of them fails for whatever reason, we cannot recover, so abort.
        guard self.fetchTasks(), !tasks.isEmpty else {
            throw SuggestionsGeneratorError.noCalculateableTasks
        }
        
        // Starting signposter for performance debugging
        let signpostId = signposter.makeSignpostID()
        let signpostState = signposter.beginInterval("calculate", id: signpostId)
        defer {
            signposter.emitEvent("Calculate complete.", id: signpostId)
            
            signposter.endInterval("calculate", signpostState)
        }

        try Task.checkCancellation()
        
        // Place each task in appropirate bins, starting with those with closest deadline and highest priority
        // This is the main part of the alogrithm
        for task in tasks {
            self.placeInBins(task: task)
            try Task.checkCancellation()
        }
        // Finished binning the tasks
        
        // Sorting the binKeys of all filled bins earliest to latest
        let sortedBinKeys = self.bins.keys.sorted()
        
        try Task.checkCancellation()
        
        // If the first entry of sortedBinKeys (i.e., The earliest bin at which the user has to work) lies before now, the user has started working too late.
        // Therefore, completing all tasks in time is infeasible.
        // Give tolerance of 1 Bin width, therfore .next
        let isFeasable = sortedBinKeys.first!.next.date >= self.now
        
        // Walk through binKeys, generating TaskWithLatestStartDate on the way for each new task we find in bins
        var tasksOrder = [TaskWithLatestStartDate]()
        var tasksSet = Set<THTask>()
        
        for binKey in sortedBinKeys {
            if let task = self.bins[binKey]?.task.task, !tasksSet.contains(task) {
                tasksOrder.append(.init(task: task, latestStartDate: binKey.date))
                tasksSet.insert(task)
            }
        }
        
        return Result(tasks: tasksOrder, isFeasible: isFeasable)
    }
}

extension SuggestionsGenerator {
    /// A Wrapper around a THTask that also contains the latest date at which the user should start working on the task.
    struct TaskWithLatestStartDate: Identifiable {
        let task: THTask
        let latestStartDate: Date
        
        var id: THTask.ID {
            task.id
        }
    }
    
    /// The struct returned by SuggestionsGenerator containing an ordered array of TaskWithLatestStartDate and a boo whether the arangement is Feasible
    struct Result {
        let tasks: [TaskWithLatestStartDate]
        let isFeasible: Bool
    }
}


