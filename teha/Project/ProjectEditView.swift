//
//  ProjectEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI


struct ProjectEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @State private var name: String = ""
    @State private var priority: Priority = .normal
    @State private var color: ColorChoice = .pink
    @State private var deadline: Date? = nil
    
    let project: THProject?
    
    init(_ mode: Mode) {
        switch mode {
        case .add:
            self.project = nil
        case .edit(let project):
            self.project = project
        }
    }
    
    var editing: Bool {
        project != nil
    }
    
    var valid: Bool {
        return !name.isEmpty
    }
    
    var navigationTitle: String {
        return editing ? name : String(localized: "new-project")
    }
    
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
                    SimpleColorPicker(title: "color", selection: $color)
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
                name = project.name ?? ""
                priority = project.priority
                color = project.color
                deadline = project.deadline
            }
        }
        .interactiveDismissDisabled()
    }
}

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
