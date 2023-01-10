//
//  ProjectEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI


struct ProjectEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name: String = ""
    @State private var priority: Priority = .normal
    @State private var color: ColorChoice = .pink
    
    let project: THProject?
    let close: () -> Void
    
    init(_ mode: Mode, close: @escaping () -> Void) {
        switch mode {
        case .add:
            self.project = nil
        case .edit(let project):
            self.project = project
        }
        self.close = close
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
        
        if !editing {
            project.creationDate = Date.now
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        close()
    }
    
    var body: some View {
        RoutedNavigation { router in
            Form {
                Section {
                    TextField(LocalizedStringKey("name"), text: $name)
                }
                Section {
                    Picker(LocalizedStringKey("priority"), selection: $priority) {
                        ForEach(Priority.allCases.reversed()) { priority in
                            Text(priority.name).tag(priority)
                        }
                    }
                    SimpleColorPicker(title: String(localized: "color"), color: $color)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey(editing ? "done" : "add")) {
                        done()
                    }
                    .disabled(!valid)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel"), role: .cancel) {
                        close()
                    }
                }
            .registerSimpleColorPicker {
                router.pop()
            }
        }
        .onAppear {
            if let project = project {
                name = project.name ?? ""
                priority = project.priority
                color = project.color
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
            ProjectEditView(.add) {
                
            }
        }
    }
}
