//
//  ProjectDetailView.swift
//  teha
//
//  Created by Alexander Baron on 13.01.23.
//

import SwiftUI
import Charts

struct ProjectStatsView: View {
    let project: THProject
    
    var tasks: [THTask] {
        guard let tasks = project.tasks else {return []}
        return Array(tasks as! Set<THTask>)
    }
    var completedTasksByDate: [Date: Int] {
        tasks.filter { $0.completionDate != nil }.reduce([:]) { (map, task) -> [Date: Int] in
            var updatedMap = map
            let completionDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: task.completionDate!)!
            
            if let value = map[completionDate] {
                updatedMap[completionDate] = value + 1
            } else {
                updatedMap[completionDate] = 1
            }
            return updatedMap
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("tasks-completed").font(.title2)
            Chart {
                ForEach(completedTasksByDate.sorted(by: >), id: \.key) { taskGroup in
                    BarMark(x: .value("", taskGroup.key), y: .value("", taskGroup.value))
                }
            }.frame(height: 256)
            Spacer()
        }.padding(.horizontal, 40)
    }
}

struct ProjectNoStatsView: View {
    var body: some View {
        VStack {
            Text("No data :(")
        }
    }
}

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let project: THProject
    
    var body: some View {
        VStack {
            if (project.tasks?.count ?? 0) > 0 {
                ProjectStatsView(project: project)
            } else {
                ProjectNoStatsView()
            }
        }
        .navigationTitle(project.name ?? "")
    }
}


struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let project = THProject(context: context)
        for i in 0..<50 {
            let task = THTask(context: context)
            task.title = "Task \(i)"
            task.completionDate = Calendar.current.date(byAdding: .day, value: Int.random(in: -6...0), to: .now)
            task.project = project
        }
        
        return ProjectDetailView(project: project)
    }
}

struct EmptyProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let project = THProject(context: context)
        project.name = "Example"
        
        return ProjectDetailView(project: project)
    }
}
