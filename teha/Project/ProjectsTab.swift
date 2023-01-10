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
    let complete: () -> Void
    
    @State private var showDeleteDialog = false
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(project.color.color)
                .fixedSize()
            Text(project.name ?? "").strikethrough(project.completed)
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
            Button { complete() } label: {
                Label("complete", systemImage: project.completed ? "xmark.rectangle.portrait" : "checkmark.rectangle.portrait")
            }
        }
    }
}

struct ProjectsTab: View {
    
    @SectionedFetchRequest<Int16, THProject>(fetchRequest: THProject.all, sectionIdentifier: \.priorityNumber)
    private var sections: SectionedFetchResults<Int16, THProject>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var addSheet: Bool = false
    @State private var editProject: THProject? = nil
    
    func projects(_ projects: Array<THProject>) -> some View {
        return ForEach(projects) { project in
            ProjectRow(project: project) {
                editProject = project
            } delete: {
                viewContext.delete(project)
            } complete: {
                project.completed = !project.completed
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sections) { section in
                    let priority = Priority(rawValue: Int(section.id))!

                    Section(priority.nameWithPriority) {
                        projects(section.filter {!$0.completed})
                    }
                }
                Section("completed") {
                    projects(sections.flatMap {$0}.filter {$0.completed})
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
