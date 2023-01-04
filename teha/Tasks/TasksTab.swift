//
//  TasksTab.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksTab: View {
    @State var searchText: String = ""
    @State var filterSheet: Bool = false
    @State var groupSheet: Bool = false
    
    var filtersAreActive: Bool {
        return true
    }
    
    var body: some View {
        NavigationStack {
            TasksListView()
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }

                }
                if filtersAreActive {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterSheet = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            groupSheet = true
                        } label: {
                            Label("Group", systemImage: "list.bullet.indent")
                        }
                        Button {
                            filterSheet = true
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }

                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
                
            }
            .sheet(isPresented: $filterSheet) {
                TasksFilterView()  {
                    filterSheet = false
                }
            }
            .confirmationDialog("Group", isPresented: $groupSheet) {
                Button {
                    
                } label: {
                    Text("Project")
                }
                Button {
                    
                } label: {
                    Text("Priority")
                }

            } message: {
                Text("Group Tasks by:")
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            Label("Tasks", systemImage: "list.bullet.rectangle.portrait")
        }
    }
}

struct TasksTab_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            TasksTab().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
