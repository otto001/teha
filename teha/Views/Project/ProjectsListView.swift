//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 11.01.23.
//

import SwiftUI
import CoreData


/// A view that displays a single project.
private struct ProjectRow: View {
    /// The project to display; this is observed so that the view is updated when the project changes in anothrer view.
    @ObservedObject var project: THProject
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Whether the delete confirmation dialog is currently presented.
    @State private var showDeleteDialog = false
    
    /// Deletes the project. If `deleteTasks` is `true`, all tasks of the project are deleted as well.
    func delete(deleteTasks: Bool) {
        if deleteTasks{
            // Remove all reminders from all tasks of the project
            //NotificationManager.instance.cancelPendingNotifications(for: project.tasks)
            
            // Delete all tasks
            (project.tasks as? Set<THTask>)?.forEach(viewContext.delete(_:))
        }
        
        viewContext.delete(project)
        // TODO: error handling
        try? viewContext.save()
    }
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(project.color.color)
                .fixedSize()
            Text(project.name ?? "").strikethrough(project.completed)
            NavigationLink("", value: NavigationPage.projectDetail(project))
        }
        // Handle the delete action, specifically what happens to the related tasks.
        .confirmationDialog("project-delete-confimation", isPresented: $showDeleteDialog) {
            if project.tasks.count > 0 {
                // Delete Project but keep tasks
                Button("delete-project-keep-tasks", role: .destructive) {
                    self.delete(deleteTasks: false)
                }
                
                // Delete Project and all of its tasks
                Button("delete-project-with-tasks", role: .destructive) {
                    self.delete(deleteTasks: true)
                }
            } else {
                // Delete Project that has no tasks
                Button("delete", role: .destructive) {
                    self.delete(deleteTasks: true)
                }
            }
            Button("cancel", role: .cancel) {
                showDeleteDialog = false
            }
        } message: {
            if project.tasks.count > 0 {
                Text("delete-project-message")
            }
        }
        .swipeActions {
            Button { showDeleteDialog = true } label: {
                Label("delete", systemImage: "trash")
            }.tint(.red)
        }
        .swipeActions(edge: .leading) {
            Button {
                project.completed = !project.completed
                try? viewContext.save()
            } label: {
                Label("complete", systemImage: project.completed ? "xmark.rectangle.portrait" : "checkmark.rectangle.portrait")
            }
        }
    }
}

/// A view that displays a list of projects.
/// The list is grouped by priority and completed status.
struct ProjectsListView: View {
    /// Fetch all projects and group them by priority and completed status
    @SectionedFetchRequest<Int, THProject>(fetchRequest: THProject.projectsListFetchRequest, sectionIdentifier: \.projectsListSection, animation: .easeInOut)
    private var sections: SectionedFetchResults<Int, THProject>
    
    /// The query to filter the projects by.
    var query: String
    
    @State private var editProject: THProject? = nil
    
    /// Get the localized name of the section with the given id.
    func sectionTitle(for id: Int) -> LocalizedStringKey {
        if id == THProject.completedSectionId {
            return LocalizedStringKey("completed")
        }
        return Priority(rawValue: id)!.nameWithPriority
    }
    
    var body: some View {
        if sections.isEmpty{
            NoProjectView()
        } else {
            List {
                ForEach(sections) { section in
                    let projects = section.search(query: query) // Filter projects by query
                    if projects.count > 0 { // Only show sections that contain projects
                        Section(sectionTitle(for: section.id)) {
                            ForEach(projects) { project in
                                ProjectRow(project: project)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .sheet(item: $editProject) { project in
                ProjectEditView(.edit(project))
            }
        }}
}

fileprivate extension SectionedFetchResults<Int, THProject>.Element {
    /// Filter the projects in this section by the given query.
    func search(query: String) -> [THProject] {
        if query == "" { return Array(self) }
        
        return Array(self).filter { $0.name?.contains(query) ?? false }
    }
}

// Implement sectioned fetch requests
fileprivate extension THProject {
    static let completedSectionId = Priority.allCases.map {$0.rawValue}.max()! + 1
    
    @objc
    var projectsListSection: Int {
        return self.completed ? THProject.completedSectionId : self.priority.rawValue
    }
    
    static var projectsListFetchRequest: NSFetchRequest<THProject> {
        let request = THProject.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \THProject.completed, ascending: true),
            NSSortDescriptor(keyPath: \THProject.priorityNumber, ascending: false),
            NSSortDescriptor(keyPath: \THProject.creationDate, ascending: true)]
        return request
    }
}

struct ProjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsListView(query: "").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
