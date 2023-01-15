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
    
    var body: some View {
        Form {
            Chart {
                LineMark(x: .value("asdf", 0), y: .value("hey", 2))
                LineMark(x: .value("asdf", 1), y: .value("hey", 4))
            }
        }
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
        Group {
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
        for i in 0..<10 {
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
