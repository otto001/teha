//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 20.12.22.
//

import SwiftUI


struct ProjectsTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var addSheet: Bool = false
    @State private var search = ""
    
    var body: some View {
        NavigationStack {
            ProjectsListView(query: search)
            .navigationDestination(for: THProject.self) { project in
                ProjectDetailView(project: project)
            }
            .navigationDestination(for: StatsViewPath.self) { path in
                TasksListView().environmentObject(path.makeFiltersViewModel()).navigationTitle(path.title)
            }
            .navigationDestination(for: THTask.self) { task in
                TaskDetailView(task: task)
            }
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
                ProjectEditView(.add)
            }
        }.searchable(text: $search)
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
