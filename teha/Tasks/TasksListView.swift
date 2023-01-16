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
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var tasks: FetchedResults<THTask>
    
    @State var taskToDelete: THTask?
    
    var showDeleteDialogBinding: Binding<Bool> {
        Binding {
            taskToDelete != nil
        } set: { newVal, _ in
            if !newVal {
                taskToDelete = nil
            }
        }

    }
    
    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
                .swipeActions(edge: .trailing) {
                    Button() {
                        taskToDelete = task
                    } label: {
                        Label("delete", systemImage: "minus.circle.fill")
                    }
                    .tint(Color.red)
                }
                .id(task.id)

        }
        .confirmationDialog("task-delete-confirmation", isPresented: showDeleteDialogBinding) {
            Button("delete", role: .destructive) {
                guard let taskToDelete = taskToDelete else { return }
                viewContext.delete(taskToDelete)
                // TODO: error handling
                try? viewContext.save()
            }
            Button("cancel", role: .cancel) {
                showDeleteDialogBinding.wrappedValue = false
            }
        } message: {
            Text("task-delete-confirmation")
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
