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
    let delete: () -> Void
    
    @State private var showDeleteDialog = false
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(project.color.color)
                .fixedSize()
            Text(project.name ?? "")
            Spacer()
            Button {
                edit()
            } label: {
                Image(systemName: "info.circle")
            }
        }
        .confirmationDialog("project-delete-confimation", isPresented: $showDeleteDialog) {
            Button("delete", role: .destructive) {
                delete()
            }
            Button("cancel", role: .cancel) {
                showDeleteDialog = false
            }
        }
        .swipeActions {
            Button { showDeleteDialog = true } label: {
                Label("delete", systemImage: "trash")
            }.tint(.red)
        }
    }
}

struct ProjectsTab: View {
    
    @SectionedFetchRequest<Int16, THProject>(fetchRequest: THProject.all, sectionIdentifier: \.priorityNumber)
    private var sections: SectionedFetchResults<Int16, THProject>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var addSheet: Bool = false
    @State private var editProject: THProject? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    let priority = Priority(rawValue: Int(section.id))!

                    Section(priority.nameWithPriority) {
                        ForEach(section) { project in
                            ProjectRow(project: project) {
                                editProject = project
                            } delete: {
                                viewContext.delete(project)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(LocalizedStringKey("projects"))
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
            Label(LocalizedStringKey("projects"), systemImage: "briefcase")
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
