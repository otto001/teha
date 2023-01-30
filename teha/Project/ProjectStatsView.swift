//
//  ProjectStatsView.swift
//  teha
//
//  Created by Alexander Baron on 15.01.23.
//

import SwiftUI
import CoreData

func isSameDay(a: DateComponents, b: DateComponents) -> Bool {
    a.year == b.year && a.month == b.month && a.day == b.day
}

enum StatsViewType {
    case all, today, finished, current
}

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

struct StatView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    let name: String
    let path: StatsViewPath
    let color: Color
    let systemName: String
    
    @State private var count: Int = 0
    
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
                    Text(LocalizedStringKey(name)).bold().font(.callout).lineLimit(1)
                    Spacer()
                    Text("\(count)").bold().font(.title)
                }
            }
            .padding(.all)
            .background(Color.tertiarySystemFill)
            .cornerRadius(8)
            .onChange(of: path) { newValue in
                fetch(project: newValue.project)
            }
            .onAppear {
                fetch(project: path.project)
            }
        }
    }
}

struct ProjectStatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let project: THProject
    
    @StateObject var tasksDueTodayFilter: TasksFilterViewModel = {
        let filter = TasksFilterViewModel()
        filter.dateFilterMode = .matchToday
        return filter
    }()
    
    @StateObject var tasksAllFilter: TasksFilterViewModel = {
        let filter = TasksFilterViewModel()
        filter.taskState = .all
        return filter
    }()
    
    @StateObject var tasksCurrentFilter: TasksFilterViewModel = {
        let filter = TasksFilterViewModel()
        filter.taskState = .current
        return filter
    }()
    
    @StateObject var tasksDoneFilter: TasksFilterViewModel = {
        let filter = TasksFilterViewModel()
        filter.taskState = .completed
        return filter
    }()
    
    func updateViewModels(with project: THProject) {
        tasksAllFilter.project = project
        tasksDoneFilter.project = project
        tasksCurrentFilter.project = project
        tasksDueTodayFilter.project = project
    }
    
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

struct ProjectStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let project = THProject(context: context)
        for i in 0..<50 {
            let task = THTask(context: context)
            task.title = "Task \(i)"
            task.completionDate = Calendar.current.date(byAdding: .day, value: Int.random(in: -6...0), to: .now)
            task.project = project
        }
        
        return ProjectStatsView(project: project)
    }
}
