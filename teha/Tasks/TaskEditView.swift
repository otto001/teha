//
//  TaskEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI



struct TaskEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss: DismissAction
    
   
    @State var data = FormData()
    
    let mode: Mode
    
    var task: THTask? {
        if case let .edit(task) = mode {
            return task
        }
        return nil
    }
    
    var editing: Bool {
        return task != nil
    }
    
    var navigationTitle: String {
        return editing ? data.title : String(localized: "new-task")
    }
    
    func done() {
        guard data.valid else { return }
        
        let task = task ?? THTask(context: viewContext)
        
        task.title = data.title
        task.notes = data.notes
        
        task.earliestStartDate = data.earliestStartDate
        task.deadline = data.deadline
        
        task.project = data.project
        
        task.reminderOffset = data.reminder
        task.reminderOffsetSecond = data.reminderSecond
        
        task.tags = data.tags as NSSet
        
        if !editing {
            task.creationDate = Date.now
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        NotificationManager.instance.scheduleReminderNotifications(task: task)
            
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(LocalizedStringKey("title"), text: $data.title)
                    ProjectPicker("project",  selection: $data.project)
                }

                Section {
                    OptionalDatePicker("earliest-startdate",
                                       addText: "earliest-startdate-add",
                                       selection: $data.earliestStartDate)
                    OptionalDatePicker("deadline",
                                       addText: "deadline-add",
                                       selection: $data.deadline)
                }

                Section {
                    ReminderPicker(title: "reminder", selection: $data.reminder)
                    if data.reminder != nil {
                        ReminderPicker(title: "reminder-second", selection: $data.reminderSecond)
                    }
                }
                
                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $data.notes)
                        .frame(minHeight: 72)
                }
                
                Section {
                    TagPicker(selection: $data.tags)
                }
            }
            .formSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: data.valid, done: done) {
                dismiss()
            }
            .onAppear {
                if let task = task {
                    self.data = .init(task: task)
                }
            }
        }
    }
}

extension TaskEditView {
    struct FormData {
        var title: String = ""
        var notes: String = ""
        var earliestStartDate: Date? = nil
        var deadline: Date? = nil
        var timeEstimate: Double? = nil
        var reminder: ReminderOffset? = nil
        var reminderSecond: ReminderOffset? = nil
        
        var project: THProject?
        
        var tags: Set<THTag> = .init()
        
        var valid: Bool {
            return !title.isEmpty
        }
        
        init() {
            
        }
        
        init(task: THTask) {
            self.title = task.title ?? ""
            self.notes = task.notes ?? ""
            self.earliestStartDate = task.earliestStartDate
            self.deadline = task.deadline
            self.timeEstimate = task.timeEstimate
            self.project = task.project
            self.tags = task.tags as? Set<THTag> ?? .init()
            self.reminder = task.reminderOffset
            self.reminderSecond = task.reminderOffsetSecond
        }
    }
    
    enum Mode {
        case add
        case edit(THTask)
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditView(mode: .add)
    }
}
