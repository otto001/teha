//
//  TasksTab.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksTab: View {
    @State var searchText: String = ""
    
    @State var taskAddSheet: Bool = false
    @State var filterSheet: Bool = false
    @State var groupSheet: Bool = false
    
    var filtersAreActive: Bool {
        return true
    }
    
    var filterSystemImage: String {
        filtersAreActive ?
        "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
    
    var body: some View {
        NavigationStack {
            TasksListView()
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        taskAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }

                }
                if filtersAreActive {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterSheet = true
                        } label: {
                            Image(systemName: filterSystemImage)
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
                            Label("Filter", systemImage: filterSystemImage)
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
            .sheet(isPresented: $taskAddSheet) {
                TaskEditView()
            }
            .confirmationDialog("Group", isPresented: $groupSheet) {
                Button {
                    
                } label: {
                    Text("None")
                }
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
