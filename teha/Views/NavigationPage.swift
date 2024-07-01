//
//  NavigationPage.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//

import Foundation
import SwiftUI

enum NavigationPage: Hashable {
    case taskDetail(THTask)
    case projectDetail(THProject)
    case projectStats(StatsViewPath)
    case timeLogEntryDetail(THTimeLogEntry)
    
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .taskDetail(let task):
            TaskDetailView(task: task)
        case .projectDetail(let project):
            ProjectDetailView(project: project)
        case .projectStats(let stats):
            TasksListView().environmentObject(stats.makeFiltersViewModel()).navigationTitle(stats.title)
        case .timeLogEntryDetail(let timeLogEntry):
            TimeLogEntryDetailView(timeLogEntry: timeLogEntry)
        }
    }
}
