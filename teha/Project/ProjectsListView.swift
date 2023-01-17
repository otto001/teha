//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 11.01.23.
//

import SwiftUI
import CoreData


private struct ProjectRow: View {
    @ObservedObject var project: THProject
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showDeleteDialog = false
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(project.color.color)
                .fixedSize()
            Text(project.name ?? "").strikethrough(project.completed)
            NavigationLink("") {
                ProjectDetailView(project: project)
            }
        }
        .confirmationDialog("project-delete-confimation", isPresented: $showDeleteDialog) {
            Button("delete", role: .destructive) {
                viewContext.delete(project)
                // TODO: error handling
                try? viewContext.save()
            }
            Button("cancel", role: .cancel) {
                showDeleteDialog = false
            }
        }
        .swipeActions {
            Button { showDeleteDialog = true } label: {
                Label("delete", systemImage: "trash")
            }.tint(.red)
            Button {
                project.completed = !project.completed
                // TODO: error handling
                try? viewContext.save()
            } label: {
                Label("complete", systemImage: project.completed ? "xmark.rectangle.portrait" : "checkmark.rectangle.portrait")
            }
        }
    }
}

struct ProjectsListView: View {
    @SectionedFetchRequest<Int, THProject>(fetchRequest: THProject.projectsListFetchRequest, sectionIdentifier: \.projectsListSection, animation: .easeInOut)
    private var sections: SectionedFetchResults<Int, THProject>
    
    var query: String
    
    @State private var editProject: THProject? = nil
    
    func sectionTitle(for id: Int) -> LocalizedStringKey {
        if id == THProject.completedSectionId {
            return LocalizedStringKey("completed")
        }
        return Priority(rawValue: id)!.nameWithPriority
    }
    
    var body: some View {
        RoutedNavigation { router in
            List {
                ForEach(sections) { section in
                    let projects = section.search(query: query)
                    if projects.count > 0 {
                        Section(sectionTitle(for: section.id)) {
                            ForEach(projects) { project in
                                ProjectRow(project: project)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $editProject) { project in
            ProjectEditView(.edit(project))
        }
    }
}

fileprivate extension SectionedFetchResults<Int, THProject>.Element {
    func search(query: String) -> [THProject] {
        if query == "" {return Array(self)}
        
        return Array(self).filter { $0.name?.contains(query) ?? false }
    }
}

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
