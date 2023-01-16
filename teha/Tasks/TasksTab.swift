//
//  TasksTab.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//


//TODO: use project picker


import SwiftUI

struct TasksTab: View {
    
    @State var taskAddSheet: Bool = false
    @State var filterSheet: Bool = false
    @State var groupSheet: Bool = false

    @StateObject var filters = TasksFilterViewModel()
    
    var filtersAreActive: Bool {
        return filters.filtersAreActive
    }
    
    var filterSystemImage: String {
        filtersAreActive ?
        "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
    
    var body: some View {
        RoutedNavigation { _ in
            TasksListView()
                .environmentObject(filters)
                .navigationDestination(for: THTask.self) { task in
                    TaskDetailView(task: task)
                }
                .searchable(text: $filters.search)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            taskAddSheet = true
                            NotificationManager.instance.requestAuthorization()
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
                                Label(LocalizedStringKey("group"), systemImage: "list.bullet.indent")
                            }
                            Button {
                                filterSheet = true
                            } label: {
                                Label(LocalizedStringKey("filter"), systemImage: filterSystemImage)
                            }
                            
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        
                    }
                    
                }
                .sheet(isPresented: $filterSheet) {
                    TasksFilterView {
                        filterSheet = false
                    }.environmentObject(filters)
                }
                .sheet(isPresented: $taskAddSheet) {
                    TaskEditView(mode: .add)
                }
                .confirmationDialog("group", isPresented: $groupSheet) {
                    Button {
                        
                    } label: {
                        Text("none")
                    }
                    Button {
                        
                    } label: {
                        Text("project")
                    }
                    Button {
                        
                    } label: {
                        Text("priority")
                    }
                    
                } message: {
                    Text("group-tasks-by")
                }
                .navigationTitle("tasks")
        }
        .tabItem {
            Label(LocalizedStringKey("tasks"), systemImage: "list.bullet.rectangle.portrait")
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
