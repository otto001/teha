//
//  TimeLogEntryEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//

import SwiftUI


/// A view that allows the user to edit or create a project.
struct TimeLogEntryEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State private var date: Date = .now
    @State private var worktime: Worktime = .zero
    @State private var tags: Set<THTag> = .init()
    @State private var notes: String = ""
    
    let task: THTask?
    let timeLogEntry: THTimeLogEntry?
    
    /// Set up the view for editing or creating a project.
    init(_ mode: Mode) {
        switch mode {
        case .add(let task):
            self.timeLogEntry = nil
            self.task = task
        case .edit(let timeLogEntry):
            self.timeLogEntry = timeLogEntry
            self.task = timeLogEntry.task
        }
    }
    
    /// Whether the view is in edit mode.
    var editing: Bool {
        timeLogEntry != nil
    }
    
    /// Whether the view is in a valid state & the user can save the project.
    var valid: Bool {
        return worktime > .zero
    }
    
    /// The title of the navigation bar.
    var navigationTitle: String {
        return editing ? String(localized: "edit-timelogentry") : String(localized: "new-timelogentry")
    }
    
    
    /// Save the project and dismiss the view.
    func done() {
        guard valid else { return }
        let editing = timeLogEntry != nil
        let timeLogEntry = timeLogEntry ?? THTimeLogEntry(context: viewContext)
        timeLogEntry.task = task
        timeLogEntry.worktime = worktime
        timeLogEntry.date = date
        timeLogEntry.tags = tags
        
        if !editing {
            timeLogEntry.creationDate = Date.now
        }
        
        task?.updateProgressFromLogs()
        
        // TODO: error handling
        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    WorktimeField(value: $worktime)
                }
                
                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $notes)
                        .frame(minHeight: 72)
                }
                
                Section {
                    TagPicker(selection: $tags)
                }
            }
            .formSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: valid, done: done) {
                dismiss()
            }
        }
        .onAppear {
            if let timeLogEntry = timeLogEntry {
                worktime = timeLogEntry.worktime
                date = timeLogEntry.date ?? .now
                tags = timeLogEntry.tags
            }
        }
        .interactiveDismissDisabled() // Prevent the user from accidentally dismissing the view
    }
}

/// The mode of the view.
extension TimeLogEntryEditView {
    enum Mode {
        case add(THTask)
        case edit(THTimeLogEntry)
    }
}


//#Preview {
//    TimeLogEntryEditView()
//}
