//
//  TasksList.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksListView: View {
    @EnvironmentObject var filter: TasksFilterViewModel
    
    var body: some View {
        FilteredTasksListView(tasks: FetchRequest(fetchRequest: filter.fetchRequest))
    }
}

fileprivate struct FilteredTasksListView: View {
    @FetchRequest var tasks: FetchedResults<THTask>
    
    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
        }
    }
}

struct TasksListView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListView()
            .environmentObject(TasksFilterViewModel())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
