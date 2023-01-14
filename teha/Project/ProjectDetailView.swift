//
//  ProjectDetailView.swift
//  teha
//
//  Created by Alexander Baron on 13.01.23.
//

import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let project: THProject
    
    @State private var name: String = ""
    @State private var priority: Priority = .normal
    @State private var color: ColorChoice = .pink
    
    // Messing around like this prevents the title from showing up only
    // after the navigation animation, while also reflecting updates
    // to the form
    private var navigationTitle: String {
        if name == "" { return project.name ?? "" }
        return name
    }
    
    var body: some View {
        Form {
            Section {
                TextField(LocalizedStringKey("name"), text: $name)
                
                Picker(LocalizedStringKey("priority"), selection: $priority) {
                    ForEach(Priority.allCases.reversed()) { priority in
                        Text(priority.name).tag(priority)
                    }
                }
                SimpleColorPicker(title: String(localized: "color"), color: $color)
            }
        }
        .navigationBarTitleDisplayMode(.inline).navigationTitle(navigationTitle)
        .onAppear {
            name = project.name ?? ""
            color = project.color
            priority = project.priority
        }
        .onDisappear {
            project.name = name
            project.color = color
            project.priority = priority
            
            try? viewContext.save()
        }
    }
}


struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let projects = try! context.fetch(THProject.fetchRequest())
        ProjectDetailView(project: projects.first!)
    }
}
