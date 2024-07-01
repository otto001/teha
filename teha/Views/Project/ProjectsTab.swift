//
//  ProjectsList.swift
//  teha
//
//  Created by Matteo Ludwig on 20.12.22.
//

import SwiftUI

/// A view that displays a list of projects.
/// This view is mainly used for navigation, and the actual list is displayed in `ProjectsListView`.
struct ProjectsTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Whether the add sheet is currently presented.
    @State private var addSheet: Bool = false
    /// The current search query.
    @State private var search = ""
    
    var body: some View {
        NavigationStack {
            ProjectsListView(query: search)
            .navigationDestination(for: NavigationPage.self) { page in
                page.view
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
