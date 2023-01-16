//
//  TaskFilterViewModel.swift
//  teha
//
//  Created by Denis Ukehaxhaj on 12.01.23.
//

import Foundation
import CoreData

class TasksFilterViewModel: ObservableObject {
    @Published var project: THProject? = nil {
        didSet {
            if project != nil {
                priority = nil
            }
        }
    }
    
    @Published var priority: Priority? = nil {
        didSet {
            if priority != nil {
                project = nil
            }
        }
    }
    
    @Published var search: String = ""

    var filtersAreActive: Bool {
        return project != nil || priority != nil
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
        
        return fetchRequest
    }
    
}
