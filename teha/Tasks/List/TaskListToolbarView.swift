//
//  TaskListToolbar.swift
//  teha
//
//  Created by Matteo Ludwig on 19.01.23.
//

import SwiftUI
import CoreData

/// struct to change the date of multiple tasks at once
fileprivate struct TasksChangeDateSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let addKey: LocalizedStringKey
    let fieldNameKey: LocalizedStringKey

    // variable for all selected tasks
    let tasks: [THTask]
    // keypath to all selected tasks and their dates
    let keypath: WritableKeyPath<THTask, Date?>
    
    @State var date: Date?

    // saves the date for all selected tasks
    func done() {
        for var task in tasks {
            task[keyPath: keypath] = date
        }

        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            // add an optionalDatePicker to change the date of the tasks
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

/// struct to change the project of multiple tasks at once
fileprivate struct TasksChangeProjectSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    let tasks: [THTask]
    @State var project: THProject?

    // save the new project for all tasks
    func done() {
        for task in tasks {
            task.project = project
        }

        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            // create a form to pick a new project
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

/// The view for the tasklistToolbar
struct TaskListToolbarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) var editMode
    
    @Binding var selected: Set<NSManagedObjectID>

    // State Bools for the different dialogs and sheets
    @State var showDeleteDialog: Bool = false
    @State var showChangeProjectSheet: Bool = false
    @State var showChangeDeadlineSheet: Bool = false
    @State var showChangeEarliestStartdateSheet: Bool = false

    // all tasks currently selected
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

    // Create the deleteButton
    @ViewBuilder var deleteButton: some View {
        Button() {
            showDeleteDialog = true
        } label: {
            Image(systemName: "trash")
        }
        // create an additional confirmationDialog if the User really wants to delete
        .confirmationDialog("tasks-delete-confirmation", isPresented: $showDeleteDialog) {
            Button("delete", role: .destructive) {
                
                for task in tasks {
                    // Remove all pending reminders for task
                    NotificationManager.instance.cancelPendingNotifications(for: task)
                    
                    viewContext.delete(task)
                }

                // remove all selected tasks
                selected.removeAll()
                editMode?.wrappedValue = .inactive

                try? viewContext.save()
            }
            // create a cancel button
            Button("cancel", role: .cancel) {
                showDeleteDialog = false
            }
        } message: {
            Text("tasks-delete-confirmation")
        }
    }

    // Create a ViewBuilder for the changing of a task progress
    @ViewBuilder var taskChangeProgressSection: some View {
        Section {
            // Creat a Button to mark a task as not started yet
            Button {
                for task in tasks {
                    task.startDate = nil
                    task.completionDate = nil
                    task.completionProgress = 0
                }
                try? viewContext.save()
            } label: {
                Label("mark-as-not-started", systemImage: "circle")
            }
            // Create a button to mark a task as started
            Button {
                for task in tasks {
                    task.started()
                    task.completionDate = nil
                    task.completionProgress = 0
                }

                try? viewContext.save()
            } label: {
                Label("mark-as-started", systemImage: "minus")
            }
            // Create a Button to mark a task as completed
            Button {
                for task in tasks {
                    task.completed()
                }

                try? viewContext.save()
            } label: {
                Label("mark-as-completed", systemImage: "circle.fill")
            }
        }
    }

    // ViewBuilder to edit a task
    @ViewBuilder var taskEditSection: some View {
        Section {
            // Create a button to change the deadline of a task
            Button {
                showChangeDeadlineSheet = true
            } label: {
                Label("deadline-change", systemImage: "calendar.badge.exclamationmark")
            }
            // Create a Button to change the earliestStartDate of a task
            Button {
                showChangeEarliestStartdateSheet = true
            } label: {
                Label("earliest-startdate-change", systemImage: "calendar")
            }
            // Create a Button to change the Project of a task
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

            // show the number of currently selected tasks
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

            // create the delete Button and add the sections
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
        // show the different sheets
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
