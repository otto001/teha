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
    
    var body: some View {
        NavigationStack {
            ProjectsListView()
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
