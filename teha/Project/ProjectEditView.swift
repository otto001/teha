//
//  ProjectEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI


struct ProjectEditView: View {
    @State private var name: String = ""
    @State private var priority: Priority = .def
    @State private var color: ColorChoice = .pink
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var close: () -> Void
    
    var valid: Bool {
        return !name.isEmpty
    }
    
    func add() {
        guard valid else { return }
        let project = THProject(context: viewContext)
        project.name = name
        project.priority = priority
        project.color = color
        
        // TODO: error handling
        try? viewContext.save()
        close()
    }
    
    var body: some View {
        RoutedNavigation {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { priority in
                            Text("\(priority.name)").tag(priority)
                        }
                    }
                    SimpleColorPicker(title: "Color", color: $color)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        add()
                    }
                    .disabled(!valid)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        close()
                    }
                }
            }
        }
    }
}

struct ProjectEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProjectEditView() {
                
            }
        }
    }
}
