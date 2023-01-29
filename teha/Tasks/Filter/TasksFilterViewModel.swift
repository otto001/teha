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
    
    @Published var search: String = ""
    
    
    private var filterActiveArray: [Bool] {
        return [project != nil, priority != nil, tagFilterMode != .disabled]
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
        
        
        return fetchRequest
    }
    
}

extension TasksFilterViewModel {
    enum TagFilterMode {
        case disabled, matchAny, matchAll
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
