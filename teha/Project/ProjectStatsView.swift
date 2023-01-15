//
//  ProjectStatsView.swift
//  teha
//
//  Created by Alexander Baron on 15.01.23.
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
