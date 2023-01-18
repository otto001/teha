//
//  TaskFilterViewModel.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import Foundation
import CoreData

class TasksFilterViewModel: ObservableObject {
    
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
}
