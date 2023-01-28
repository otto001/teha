//
//  TaskListToolbar.swift
//  teha
//
//  Created by Matteo Ludwig on 19.01.23.
//

import SwiftUI
import CoreData

fileprivate struct TasksChangeDateSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let addKey: LocalizedStringKey
    let fieldNameKey: LocalizedStringKey
    
    let tasks: [THTask]
    let keypath: WritableKeyPath<THTask, Date?>
    
    @State var date: Date?
    
    func done() {
        for var task in tasks {
            task[keyPath: keypath] = date
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                OptionalDatePicker(fieldNameKey, addText: addKey, selection: $date)
            }
            .formSheetNavigationBar(navigationTitle: title,
                                    editing: true,
                                    valid: true,
                                    done: done) {
                dismiss()
            }
        }
        .onAppear {
            let dates = Set(tasks.map { $0[keyPath: keypath] })
            if dates.count == 1 {
                date = dates.first!
            }
        }
    }
}

fileprivate struct TasksChangeProjectSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    let tasks: [THTask]
    @State var project: THProject?
    
    func done() {
        for task in tasks {
            task.project = project
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                ProjectPicker("project", selection: $project)
            }
            .formSheetNavigationBar(navigationTitle: String(localized: "project-change"),
                                     editing: true,
                                     valid: true,
                                     done: done) {
                 dismiss()
             }
        }
        .onAppear {
            let projects = Set(tasks.map { $0.project })
            if projects.count == 1 {
                project = projects.first!
            }
        }
    }
}

struct TaskListToolbarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var selected: Set<NSManagedObjectID>
    
    @State var showDeleteDialog: Bool = false
    @State var showChangeProjectSheet: Bool = false
    @State var showChangeDeadlineSheet: Bool = false
    @State var showChangeEarliestStartdateSheet: Bool = false
    
    var tasks: [THTask] {
        selected
            .compactMap { try? viewContext.existingObject(with: $0) as? THTask }
            .sorted { a, b in
                a.priority < b.priority
            }
    }
    
    var shareText: String {
        tasks.compactMap {
            guard let title = $0.title else { return nil }
            return "- \(title)"
            
        }.joined(separator: "\n")
    }
    
    @ViewBuilder var deleteButton: some View {
        Button() {
            showDeleteDialog = true
        } label: {
            Image(systemName: "trash")
        }
        .confirmationDialog("tasks-delete-confirmation", isPresented: $showDeleteDialog) {
            Button("delete", role: .destructive) {
                
                for task in tasks {
                    // Remove all pending reminders for task
                    NotificationManager.instance.cancelPendingNotifications(taskid: task.taskId)
                    
                    viewContext.delete(task)
                }
                
                selected.removeAll()
                
                // TODO: error handling
                try? viewContext.save()
            }
            Button("cancel", role: .cancel) {
                showDeleteDialog = false
            }
        } message: {
            Text("tasks-delete-confirmation")
        }
    }
    
    @ViewBuilder var taskChangeProgressSection: some View {
        Section {
            Button {
                for task in tasks {
                    task.startDate = nil
                    task.completionDate = nil
                    task.completionProgress = 0
                }
                // TODO: error handling
                try? viewContext.save()
            } label: {
                // TODO: change icons?
                Label("mark-as-not-started", systemImage: "play.circle")
            }
            
            Button {
                for task in tasks {
                    task.started()
                    task.completionDate = nil
                    task.completionProgress = 0
                }
                // TODO: error handling
                try? viewContext.save()
            } label: {
                // TODO: change icons?
                Label("mark-as-started", systemImage: "play.circle")
            }
            
            Button {
                for task in tasks {
                    task.completed()
                }
                // TODO: error handling
                try? viewContext.save()
            } label: {
                // TODO: change icons?
                Label("mark-as-completed", systemImage: "play.circle")
            }
        }
    }
    
    @ViewBuilder var taskEditSection: some View {
        Section {
            Button {
                showChangeDeadlineSheet = true
            } label: {
                Label("deadline-change", systemImage: "play.circle")
            }
            Button {
                showChangeEarliestStartdateSheet = true
            } label: {
                Label("earliest-startdate-change", systemImage: "play.circle")
            }
            Button {
                showChangeProjectSheet = true
            } label: {
                Label("project-change", systemImage: "briefcase")
            }
        }
    }
    
    var body: some View {

        HStack {
            HStack {
                ShareLink("", item: shareText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            
            Group {
                if selected.isEmpty {
                    Text("select-tasks")
                        .fontWeight(.semibold)
                } else {
                    Text("\(selected.count)-tasks-selected")
                        .fontWeight(.semibold)
                }
            }
            .layoutPriority(2)

            
            HStack {
                deleteButton
                
                Menu {
                    taskChangeProgressSection
                    
                    taskEditSection
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .sheet(isPresented: $showChangeProjectSheet) {
            TasksChangeProjectSheet(tasks: tasks).presentationDetents([.height(220)])
        }
        .sheet(isPresented: $showChangeDeadlineSheet) {
            TasksChangeDateSheet(title: String(localized: "deadline-change"), addKey: "deadline-add", fieldNameKey: "deadline", tasks: tasks, keypath: \.deadline).presentationDetents([.height(220)])
        }
        .sheet(isPresented: $showChangeEarliestStartdateSheet) {
            TasksChangeDateSheet(title: String(localized: "earliest-startdate-change"), addKey: "earliest-startdate-add", fieldNameKey: "earliest-startdate", tasks: tasks, keypath: \.earliestStartDate).presentationDetents([.height(220)])
        }
    }
}

struct TaskListToolbarView_Previews: PreviewProvider {
    struct TaskListToolbarViewPreview: View {
        @State var selected: Set<NSManagedObjectID> = .init()
        
        var body: some View {
            TaskListToolbarView(selected: $selected)
        }
    }
    
    static var previews: some View {
        TaskListToolbarViewPreview()
    }
}
