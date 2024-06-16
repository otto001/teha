//
//  ProjectStatsView.swift
//  teha
//
//  Created by Alexander Baron on 15.01.23.
//

import SwiftUI
import CoreData

enum StatsViewType {
    case all, today, finished, current
}

/// This struct is pushed onto the navigation stack to display the tasks matching the filter.
struct StatsViewPath: Hashable {
    let type: StatsViewType
    let project: THProject
    
    var title: LocalizedStringKey {
        switch type {
        case .all:
            return LocalizedStringKey("all")
        case .current:
            return LocalizedStringKey("current")
        case .finished:
            return LocalizedStringKey("tasks-finished")
        case .today:
            return LocalizedStringKey("tasks-due-today")
        }
    }
    
    /// Generate a filter viewmodel in order to fetch the tasks matching the path.
    func makeFiltersViewModel() -> TasksFilterViewModel {
        let filter = TasksFilterViewModel()
        filter.taskState = .current
        filter.dateFilterMode = .disabled
        
        switch type {
        case .all:
            filter.taskState = .all
        case .current:
            filter.taskState = .current
        case .finished:
            filter.taskState = .completed
        case .today:
            filter.dateFilterMode = .matchToday
        }
        
        filter.project = project
        return filter
    }
}

/// A view that displays a single stat.
/// The stat is a count of the number of tasks matching the filter.
struct StatView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    let name: String
    let path: StatsViewPath
    let color: Color
    let systemName: String
    
    // The number of tasks matching the filter.
    // This is a state variable so it can be set asynchronously.
    @State private var count: Int = 0
    
    /// Fetch the number of tasks matching the filter.
    private func fetch(project: THProject) {
        let filter = path.makeFiltersViewModel()
        let request = filter.fetchRequest
        self.count = (try? viewContext.fetch(request))?.count ?? 0
    }
    
    var body: some View {
        NavigationLink(value: path) {
            VStack(alignment: .leading) {
                ZStack {
                    Circle().frame(width: 32).foregroundStyle(color)
                    Image(systemName: systemName).foregroundStyle(.white)
                }
                HStack {
                    Text(LocalizedStringKey(name)).bold().font(.callout).lineLimit(1).foregroundColor(.label)
                    Spacer()
                    Text("\(count)").bold().font(.title).foregroundColor(.label)
                }
            }
            .padding(.all)
            .background(Color.tertiarySystemFill)
            .cornerRadius(8)
            .onChange(of: path) { newValue in
                // If the filter changes, fetch the new count.
                fetch(project: newValue.project)
            }
            .onAppear {
                fetch(project: path.project)
            }
        }
    }
}

/// A view that displays the stats for a project.
/// When a stat is tapped, it pushes a new view onto the navigation stack.
struct ProjectStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let project: THProject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                StatView(name: "all", path: .init(type: .all, project: project), color: .blue, systemName: "circle")
                StatView(name: "tasks-due-today", path: .init(type: .today, project: project), color: .orange, systemName: "calendar.badge.exclamationmark")
            }
            HStack(spacing: 12) {
                StatView(name: "current", path: .init(type: .current, project: project), color: .mint, systemName: "minus")
                StatView(name: "tasks-finished", path: .init(type: .finished, project: project), color: .green, systemName: "circle.fill")
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        
    }
}

//struct ProjectStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        
//        let project = THProject(context: context)
//        for i in 0..<50 {
//            let task = THTask(context: context)
//            task.title = "Task \(i)"
//            task.completionDate = Calendar.current.date(byAdding: .day, value: Int.random(in: -6...0), to: .now)
//            task.project = project
//        }
//        
//        return ProjectStatsView(project: project)
//    }
//}
