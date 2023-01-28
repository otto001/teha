//
//  TasksList.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI
import CoreData


struct TasksListView: View {
    @EnvironmentObject var filter: TasksFilterViewModel
    
    var body: some View {
        FilteredTasksListView(tasks: FetchRequest(fetchRequest: filter.fetchRequest))
    }
}

fileprivate struct FilteredTasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) var editMode
    
    @FetchRequest var tasks: FetchedResults<THTask>
    
    @State var selectedTasks: Set<NSManagedObjectID> = .init()
    
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
        List(tasks, id: \.objectID, selection: $selectedTasks) { task in
            TaskRowView(task: task)
                .swipeActions(edge: .trailing) {
                    Button() {
                        taskToDelete = task
                    } label: {
                        Label("delete", systemImage: "trash")
                    }
                    .tint(Color.red)
                }
                .disabled(editMode?.wrappedValue == .active)
                .id(task.id)
        }
        .onAppear {
            // Evertime the user navigates back to this view (which calls onAppear), we need to manually clear the selection.
            // This is due to SwiftUI adding the rows tapped for navigation purposes to the selection, which is an annoying, not yet fixed bug.
            // This behaviour causes SwiftUI to be rather unpredicable (aka: the row entries start to rave) when navigating or selecting, unless you manually clear the selection like we do here.
            selectedTasks.removeAll()
        }
        .toolbar {
            if editMode?.wrappedValue == .active {
                ToolbarItem(placement: .bottomBar) {
                    TaskListToolbarView(selected: $selectedTasks)
                        .padding(.horizontal, -10)
                        .padding(.top, -6)
                }
            }
            
        }
        .confirmationDialog("task-delete-confirmation", isPresented: showDeleteDialogBinding) {
            Button("delete", role: .destructive) {
                guard let taskToDelete = taskToDelete else { return }
                
                // Remove all pending reminders for task
                NotificationManager.instance.cancelPendingNotifications(taskid: taskToDelete.taskId)
                
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
        TabView {
            NavigationStack {
                TasksListView()
                    .environmentObject(TasksFilterViewModel())
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
    }
}
