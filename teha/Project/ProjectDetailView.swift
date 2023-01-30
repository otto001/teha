//
//  ProjectDetailView.swift
//  teha
//
//  Created by Alexander Baron on 13.01.23.
//

import SwiftUI

struct ProjectNoStatsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet").font(.largeTitle)
            Text("tasks-none")
        }
    }
}

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var edit = false
    
    let project: THProject
    
    var body: some View {
        Group {
            if (project.tasks?.count ?? 0) > 0 {
                ProjectStatsView(project: project)
            } else {
                VStack {
                    ProjectNoStatsView()
                }
            }
        }
        .navigationTitle(project.name ?? "")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("edit") {
                    edit = true
                }
            }
        }
        .sheet(isPresented: $edit) {
            ProjectEditView(.edit(project))
        }
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
