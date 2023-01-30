//
//  ProjectEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI


/// A view that allows the user to edit or create a project.
struct ProjectEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss: DismissAction
    
    // Used for setting the default deadline
    @AppStorage(SettingsAppStorageKey.endOfWorkDay.rawValue) var endOfWorkDay: Worktime = .init(hours: 16, minutes: 0)
    
    @State private var name: String = ""
    @State private var priority: Priority = .normal
    @State private var color: ColorChoice = .pink
    @State private var deadline: Date? = nil
    
    let project: THProject?
    
    /// Set up the view for editing or creating a project.
    init(_ mode: Mode) {
        switch mode {
        case .add:
            self.project = nil
        case .edit(let project):
            self.project = project
        }
    }
    
    /// Whether the view is in edit mode.
    var editing: Bool {
        project != nil
    }
    
    /// Whether the view is in a valid state & the user can save the project.
    var valid: Bool {
        return !name.isEmpty
    }
    
    /// The title of the navigation bar.
    var navigationTitle: String {
        return editing ? name : String(localized: "new-project")
    }
    
    /// The default deadline for a new project, this is the end of the work day in 7 days.
    var defaultDeadline: Date {
        var date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        date = Calendar.current.date(bySettingHour: endOfWorkDay.hours, minute: endOfWorkDay.minutes, second: 0, of: date) ?? .now
        return date
    }
    
    /// Save the project and dismiss the view.
    func done() {
        guard valid else { return }
        let editing = project != nil
        let project = project ?? THProject(context: viewContext)
        project.name = name
        project.priority = priority
        project.color = color
        project.deadline = deadline
        
        if !editing {
            project.creationDate = Date.now
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(LocalizedStringKey("name"), text: $name)
                }

                Section {
                    PriorityPicker("priority", selection: $priority)
                    SimpleColorPicker(title: "color", selection: $color, allowCustomColor: true)
                    OptionalDatePicker("deadline",
                                       addText: "deadline-add",
                                       selection: $deadline,
                                       defaultDate: Calendar.current.date(byAdding: .month, value: 1, to: .now)!)
                }
            }
            .formSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: valid, done: done) {
                dismiss()
            }
        }
        .onAppear {
            if let project = project {
                // Set the initial values to the project's values
                name = project.name ?? ""
                priority = project.priority
                color = project.color
                deadline = project.deadline
            }
        }
        .interactiveDismissDisabled() // Prevent the user from accidentally dismissing the view
    }
}

/// The mode of the view.
extension ProjectEditView {
    enum Mode {
        case add
        case edit(THProject)
    }
}

struct ProjectEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectEditView(.add)
        }
    }
}
