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
    
    @Published var grouping: TasksGrouping = .week
    
    @Published var taskState: TaskStateFilter = .current
    
    @Published var project: THProject? = nil
    
    @Published var priority: Priority? = nil
    
    @Published var tagFilterMode: TagFilterMode = .disabled
    @Published var tags: Set<THTag> = .init()
    
    @Published var _upcomingFilterMode: DateFilterMode = .disabled
    @Published var upcomingInterval: DateInterval = DateInterval()
    
    @Published var _deadlineFilterMode: DateFilterMode = .disabled
    @Published var deadlineInterval: DateInterval = DateInterval()
    
    @Published var search: String = ""
    
    init() {
        self.upcomingInterval = self.today()
        self.deadlineInterval = self.today()
    }
    
    /**
        Property representing the upcomingfilter mode.
        When the value is set to:
        - .matchToday: the `upcomingInterval` property is updated to represent the current day.
        - .matchThisWeek: the `upcomingInterval` property is updated to represent the current week.
        - .custom: the `upcomingInterval` property is left unchanged.
        - .disabled: the `upcomingInterval` property is left unchanged.
     */
    var dateFilterMode: DateFilterMode{
        get {
            return _upcomingFilterMode
        }
        set {
            _upcomingFilterMode = newValue
            if _upcomingFilterMode == .matchToday {
                upcomingInterval = today()
            } else if _upcomingFilterMode == .matchThisWeek {
                upcomingInterval = thisWeek()
            }
        }
    }
    
    /**
        Property representing the current deadline filter mode.
        When the value is set to:
        - .matchToday: the `deadlineInterval` property is updated to represent the current day.
        - .matchThisWeek: the `deadlineInterval` property is updated to represent the current week.
        - .custom: the `deadlineInterval` property is left unchanged.
        - .disabled: the `deadlineInterval` property is left unchanged.
     */
    var deadlineFilterMode: DateFilterMode{
        get {
            return _deadlineFilterMode
        }
        set {
            _deadlineFilterMode = newValue
            if _deadlineFilterMode == .matchToday {
                deadlineInterval = today()
            } else if _deadlineFilterMode == .matchThisWeek {
                deadlineInterval = thisWeek()
            }
        }
    }
    
    private var filterActiveArray: [Bool] {
        return [project != nil, priority != nil, tagFilterMode != .disabled, dateFilterMode != .disabled, deadlineFilterMode != .disabled]
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
            fetchRequest.filter(dateInterval: upcomingInterval)
        default:
            break
        }
        
        switch deadlineFilterMode{
        case .matchToday, .matchThisWeek, .custom:
            fetchRequest.filter(deadline: deadlineInterval)
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
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.startOfDay(for: now) + TimeInterval.day
        
        return DateInterval(start: startOfDay, end: endOfDay)
    }
    
    /**
     Returns the date interval for the current week, starting from Monday 00:00 AM  and ending on Sunday 11:59 PM.
     
     - Returns: A `DateInterval` object representing the current week. If a created optional is `nil`, the function will return a `deafaultInterval` which will return a `DateInterval` object where start and end time is equal to the current time.
    */
    private func thisWeek() -> DateInterval {
        let now = Date()
        
        let startOfWeek = now.startOfWeek
        let startOfNextWeek = startOfWeek + TimeInterval.week
        return DateInterval(start: startOfWeek, end: startOfNextWeek)
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
    
    enum TasksGrouping: CaseIterable, Identifiable {
        case day, week, month, year
        
        var id: Self {
            return self
        }
        
        var name: LocalizedStringKey {
            switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            }
        }
    }
}
