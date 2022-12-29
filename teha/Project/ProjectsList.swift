//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 20.12.22.
//

import SwiftUI

private struct ProjectRow: View {
    let project: Project
    
    var body: some View {
        Text(project.name ?? "")
            .foregroundColor(project.color.color)
    }
}

struct ProjectsList: View {
    
    @SectionedFetchRequest<Int16, Project>(fetchRequest: Project.all, sectionIdentifier: \.priorityNumber)
    private var sections: SectionedFetchResults<Int16, Project>
    
    @State private var addSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    let priority = Priority(rawValue: Int(section.id))!
                    Section("\(priority.name) Priority") {
                        ForEach(section) { project in
                            ProjectRow(project: project)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        addSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }
            }
            .sheet(isPresented: $addSheet) {
                ProjectEditView {
                    addSheet = false
                }
            }
        }
    }
}

struct ProjectsList_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsList()
    }
}
