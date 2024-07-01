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

    // The variable used for grouping the tasks into different timeslots, default: .week
    @Published var grouping: TasksGrouping = .week

    // The taskstate used to filter for a specific taskstate, default: .current
    @Published var taskState: TaskStateFilter = .current

    // The Project used to filter for a specific project
    @Published var project: THProject? = nil

    // The priority used to filter for a specific priority
    @Published var priority: Priority? = nil

    // The TagFiltermode used when filtering by tags
    @Published var tagFilterMode: TagFilterMode = .disabled
    // The set of tags to filter by
    @Published var tags: Set<THTag> = .init()

    // internal states, see dateFilterMode
    @Published private var _upcomingFilterMode: DateFilterMode = .disabled
    // DateInterval where all tasks are shown that can be active during the DateInterval
    @Published var upcomingInterval: DateInterval = DateInterval()

    // internal states, see dateFilterMode
    @Published private var _deadlineFilterMode: DateFilterMode = .disabled
    // DateInterval where all tasks are shown that that have a deadline during the DateInterval
    @Published var deadlineInterval: DateInterval = DateInterval()
    
    
    @Published var excludeWithoutDeadline: Bool = false
    
    
    /// Filter flag for recurring tasks
    @Published var recurringTask: Bool = false
    
    // The User input from the search bar
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
    var dateFilterMode: DateFilterMode {
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

    // variable containing all currently active filters
    private var filterActiveArray: [Bool] {
        return [project != nil, priority != nil, tagFilterMode != .disabled, dateFilterMode != .disabled, deadlineFilterMode != .disabled, recurringTask == true]
    }

    // variable that returns true if any filter is active
    var anyFilterActive: Bool {
        return !filterActiveArray.allSatisfy { !$0 }
    }

    // variable that returns true if all filters are active
    var allFiltersActive: Bool {
        return filterActiveArray.allSatisfy { $0 }
    }

    // The fetchRequest for all THTasks of the User
    var fetchRequest: NSFetchRequest<THTask> {
        let fetchRequest = THTask.all

        // filter by the currently selected taskState
        switch taskState {
        case .current:
            fetchRequest.filter(completed: false)
        case .completed:
            fetchRequest.filter(completed: true)
        case .all:
            break
        }

        // filter by the currently selected project
        if let project = self.project {
            fetchRequest.filter(project: project)
        }

        // filter by the currently selected priority
        if let priority = self.priority {
            fetchRequest.filter(priority: priority)
        }

        // If the user has put anything into the searchBar, filter by the search string
        if !self.search.isEmpty {
            fetchRequest.filter(search: self.search)
        }
        
        // filter by recurring tasks
        if recurringTask {
            fetchRequest.filterReoccuringTask()
        }
        
        // filter by currently selected tags and the tagFilterMode
        switch tagFilterMode {
        case .matchAny:
            fetchRequest.filter(tags: tags, mode: .matchAny)
        case .matchAll:
            fetchRequest.filter(tags: tags, mode: .matchAll)
        default:
            break
        }

        // filter by the dateInterval of the dateFilterMode
        switch dateFilterMode {
        case .matchToday, .matchThisWeek, .custom:
            fetchRequest.filter(dateInterval: upcomingInterval)
        default:
            break
        }

        // filter by the dateInterval of the deadlineFilterMode
        switch deadlineFilterMode {
        case .matchToday, .matchThisWeek, .custom:
            fetchRequest.filter(deadline: deadlineInterval)
        default:
            break
        }
        
        if self.excludeWithoutDeadline {
            fetchRequest.filterExcludeWithoutDeadline()
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
    /// enum representing the different tagFilterModes
    enum TagFilterMode {
        /// Filter is turned off
        case disabled
        /// If any tag of a task matches to any tag from the filter, the task is shown
        case matchAny
        ///If the tags from a task match to all tags from the filter, the task is shown
        case matchAll
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

    /// enum representing the different TaskStateFilter
    enum TaskStateFilter: CaseIterable, Identifiable {
        /// Show all tasks
        case all
        /// Show all non-completed tasks
        case current
        /// Show all completed tasks
        case completed
        
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

    /// Enum representing the grouping of tasks by a different timeslot
    enum TasksGrouping: CaseIterable, Identifiable {
        /// Group all tasks by days
        case day
        /// Group all tasks by weeks
        case week
        /// Group all tasks by months
        case month
        /// Group all tasks by year
        case year
        
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
