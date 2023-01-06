//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 20.12.22.
//

import SwiftUI

private struct ProjectRow: View {
    let project: THProject
    let edit: () -> Void
    
    var body: some View {
        HStack {
            Text(project.name ?? "")
                .foregroundColor(project.color.color)
            Spacer()
            Button {
                edit()
            } label: {
                Image(systemName: "info.circle")
            }

        }
    }
}

struct ProjectsTab: View {
    
    @SectionedFetchRequest<Int16, THProject>(fetchRequest: THProject.all, sectionIdentifier: \.priorityNumber)
    private var sections: SectionedFetchResults<Int16, THProject>
    
    @State private var addSheet: Bool = false
    @State private var editProject: THProject? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    let priority = Priority(rawValue: Int(section.id))!
                    
                    Section("\(priority.name) Priority") {
                        ForEach(section) { project in
                            ProjectRow(project: project) {
                                editProject = project
                            }
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
                ProjectEditView(.add) {
                    addSheet = false
                }
            }
            .sheet(item: $editProject) { project in
                ProjectEditView(.edit(project)) {
                    editProject = nil
                }
            }
        }
        .tabItem {
            Label("Projects", systemImage: "briefcase")
        }
    }
}

struct ProjectsTab_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ProjectsTab().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
