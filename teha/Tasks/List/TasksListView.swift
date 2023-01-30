//
//  TasksList.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI
import CoreData



struct TasksListView: View {
    @EnvironmentObject var filters: TasksFilterViewModel
    
    var fetchRequest: SectionedFetchRequest<String, THTask> {
        switch filters.grouping {
        case .year:
            return SectionedFetchRequest(fetchRequest: filters.fetchRequest, sectionIdentifier: \THTask.deadlineYearString)
        case .month:
            return SectionedFetchRequest(fetchRequest: filters.fetchRequest, sectionIdentifier: \THTask.deadlineMonthString)
        case .week:
            return SectionedFetchRequest(fetchRequest: filters.fetchRequest, sectionIdentifier: \THTask.deadlineWeekString)
        case .day:
            return SectionedFetchRequest(fetchRequest: filters.fetchRequest, sectionIdentifier: \THTask.deadlineDayString)
        }
    }
    
    var body: some View {
        FilteredTasksListView(sections: fetchRequest)
    }
}


/// The actual view that shows a list of tasks.
/// TasksListView is just a proxy needed due to SwiftUI reasons (wrapping the FetchRequest)
fileprivate struct FilteredTasksListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var filters: TasksFilterViewModel
    
    @SectionedFetchRequest var sections: SectionedFetchResults<String, THTask>
    
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
    
    @State private var now = Date()


    var body: some View {
        
        if filters.anyFilterActive && sections.isEmpty {
            NoTaskFilterView()
        }
        else if sections.isEmpty{
            NoTaskView()
        }
        
        else {
            List(selection: $selectedTasks) {
                ForEach(sections) { section in
                    TaskListSectionView(section, now: now) { task in
                        taskToDelete = task
                    }
                }
            }
            .autoRefresh(now: $now)
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
                    NotificationManager.instance.cancelPendingNotifications(for: taskToDelete)
                    
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
