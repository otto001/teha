//
//  ProjectStatsView.swift
//  teha
//
//  Created by Alexander Baron on 15.01.23.
//

import SwiftUI

struct StatView: View {
    let name: String
    let value: Float
    let color: Color
    let systemName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                ZStack {
                    Circle().frame(width: 32).foregroundStyle(color)
                    Image(systemName: systemName).foregroundStyle(.white)
                }
                Text(name).bold().font(.callout).lineLimit(1)
            }
            Spacer()
            Text(String(format: "%.0f", value)).bold().font(.title)
        }
        .padding(.all)
        .background(.quaternary)
        .cornerRadius(8)
    }
}

struct ProjectStatsView: View {
    let project: THProject
    
    var tasks: [THTask] {
        guard let tasks = project.tasks else {return []}
        return Array(tasks as! Set<THTask>)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                StatView(name: "Test", value: 8, color: .blue, systemName: "function")
                StatView(name: "Hello", value: 3, color: .orange, systemName: "flag.fill")
            }
            HStack(spacing: 12) {
                StatView(name: "More stats", value: 32, color: .pink, systemName: "paintbrush")
                StatView(name: "Dataaaa", value: 7, color: .gray, systemName: "skew")
            }
            Spacer()
        }.padding(.horizontal, 24)
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
