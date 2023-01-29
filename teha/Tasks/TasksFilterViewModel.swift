//
//  TaskFilterViewModel.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import Foundation
import CoreData
import SwiftUI


class TasksFilterViewModel: ObservableObject {
    
    @Published var project: THProject? = nil
    
    @Published var priority: Priority? = nil
    
    @Published var tagFilterMode: TagFilterMode = .disabled
    @Published var tags: Set<THTag> = .init()
    
    @Published var _dateFilterMode: DateFilterMode = .disabled
    @Published var dateInterval: DateInterval = DateInterval()
    
    @Published var search: String = ""
    
    @Published var taskState: TaskStateFilter = .current
    
    
    var dateFilterMode: DateFilterMode{
        get {
            return _dateFilterMode
        }
        set {
            _dateFilterMode = newValue
            if _dateFilterMode == .matchToday {
                dateInterval = today()
            } else if _dateFilterMode == .matchThisWeek {
                dateInterval = thisWeek()
            }
            print("dateinterval: \(dateInterval)")
            print("set: \(_dateFilterMode)")
        }
    }
    
    private var filterActiveArray: [Bool] {
        return [project != nil, priority != nil, tagFilterMode != .disabled, dateFilterMode != .disabled]
    }

    var anyFilterActive: Bool {
        return !filterActiveArray.allSatisfy { !$0 }
    }
    
    var allFiltersActive: Bool {
        return filterActiveArray.allSatisfy { $0 }
    }
    
    var fetchRequest: NSFetchRequest<THTask> {
        let fetchRequest = THTask.all
        
        switch taskState {
        case .current:
            fetchRequest.filter(completed: false)
        case .completed:
            fetchRequest.filter(completed: true)
        case .all:
            break
        }
        
        if let project = self.project {
            fetchRequest.filter(project: project)
        }
        
        if let priority = self.priority {
            fetchRequest.filter(priority: priority)
        }
        
        if !self.search.isEmpty {
            fetchRequest.filter(search: self.search)
        }
        
        switch tagFilterMode{
        case .matchAny:
            fetchRequest.filter(tags: tags, mode: .matchAny)
        case .matchAll:
            fetchRequest.filter(tags: tags, mode: .matchAll)
        default:
            break
        }
        
        switch dateFilterMode{
        case .matchToday, .matchThisWeek, .custom:
            fetchRequest.filter(dateInterval: dateInterval)
        default:
            break
        }
        
        return fetchRequest
    }
    
    /**
     Returns the date interval for today, starting from 00:00 AM  and ending on 11:59 PM.
     
     - Returns: A `DateInterval` object representing today. If a created optional is `nil`, the function will return a `deafaultInterval` which will return a `DateInterval` object where start and end time is equal to the current time.
    */
    private func today() -> DateInterval {
        let defaultDate = DateInterval()
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: now) else { return defaultDate }
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else { return defaultDate }
        return DateInterval(start: startOfDay, end: endOfDay)
    }
    
    /**
     Returns the date interval for the current week, starting from Monday 00:00 AM  and ending on Sunday 11:59 PM.
     
     - Returns: A `DateInterval` object representing the current week. If a created optional is `nil`, the function will return a `deafaultInterval` which will return a `DateInterval` object where start and end time is equal to the current time.
    */
    private func thisWeek() -> DateInterval {
        let defaultDate = DateInterval()
        
        var calendar = Calendar.current
        let now = Date()
        guard var startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return defaultDate }
        guard var startOfWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek) else { return defaultDate }
        guard var startOfWeek = calendar.date(byAdding: .day, value: 1, to: startOfWeek) else { return defaultDate }
        guard var endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else { return defaultDate }
        guard var endOfWeek = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek) else { return defaultDate }
        return DateInterval(start: startOfWeek, end: endOfWeek)
    }
    
}

extension TasksFilterViewModel {
    enum TagFilterMode {
        case disabled, matchAny, matchAll
    }
    
    
    /**
     Enumeration representing different modes for filtering dates.
        Cases:
         - `disabled`: The filter is turned off.
         - `matchToday`: The filter should match the current day.
         - `matchThisWeek`: The filter should match the current week.
         - `custom`: The filter is set to a specific date interval.
    */
    enum DateFilterMode {
        case disabled, matchToday, matchThisWeek, custom
    }
    
    enum TaskStateFilter: CaseIterable, Identifiable {
        case all, current, completed
        var id: Self {
            return self
        }
        
        var name: LocalizedStringKey {
            switch self {
            case .all: return "all"
            case .current: return "current"
            case .completed: return "completed"
            }
        }
    }
    
}
