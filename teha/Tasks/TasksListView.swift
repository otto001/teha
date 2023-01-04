//
//  TasksList.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksListView: View {
    @FetchRequest(fetchRequest: THTask.all) var tasks: FetchedResults<THTask>
    
    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
        }
    }
}

struct TasksListView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
