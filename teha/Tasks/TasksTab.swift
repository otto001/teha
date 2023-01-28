//
//  TasksTab.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//


import SwiftUI

fileprivate struct TasksTabFiltersActiveButton: View {
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var filters: TasksFilterViewModel
    
    @State var filterSheet: Bool  = false
    
    var body: some View {
        ZStack {
            if filters.anyFilterActive {
                Button {
                    filterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                }
                .disabled(editMode?.wrappedValue == .active)
                
            }
        }
        .sheet(isPresented: $filterSheet) {
            TasksFilterView()
        }
    }
}

fileprivate struct TasksTabMoreButton: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var filters: TasksFilterViewModel
    
    @State var groupSheet: Bool = false
    @State var filterSheet: Bool = false
    
    
    var filterSystemImage: String {
        filters.anyFilterActive ?
        "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
    
    @ViewBuilder private func withGroupingDialog(@ViewBuilder _ view: () -> some View) -> some View {
        view()
        .confirmationDialog("group", isPresented: $groupSheet) {
            ForEach(TasksFilterViewModel.TasksGrouping.allCases) { option in
                Button {
                    filters.grouping = option
                } label: {
                    Text(option.name)
                }
            }
            
        } message: {
            Text("group-tasks-by")
        }
    }
    
    @ViewBuilder private var buttons: some View {
        if horizontalSizeClass == .compact {
            withGroupingDialog {
                Menu {
                    Button {
                        filterSheet = true
                    } label: {
                        Label(LocalizedStringKey("filter"), systemImage: filterSystemImage)
                    }
                    Button {
                        groupSheet = true
                    } label: {
                        Label(LocalizedStringKey("group"), systemImage: "list.bullet.indent")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        } else {
            HStack {
                withGroupingDialog {
                    Button {
                        groupSheet = true
                    } label: {
                        Text("group")
                    }
                }
                
                Button {
                    filterSheet = true
                } label: {
                    Text("filter")
                }
            }
        }
    }
    
    var body: some View {
       
        buttons
        .sheet(isPresented: $filterSheet) {
            TasksFilterView()
        }
        .disabled(editMode?.wrappedValue == .active)
        
    }
}

struct TasksTab: View {
    @Environment(\.editMode) var editMode
    
    @State var taskAddSheet: Bool = false
    
    @StateObject var filters = TasksFilterViewModel()
    
    var filtersAreActive: Bool {
        return filters.anyFilterActive
    }
    
    var body: some View {
        
        NavigationStack {
            TasksListView()
                .environment(\.editMode, editMode)
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
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            
                            TasksTabFiltersActiveButton().environment(\.editMode, editMode)
                            
                            Button {
                                withAnimation {
                                    editMode?.wrappedValue = (editMode?.wrappedValue.isEditing == true ? EditMode.inactive : EditMode.active)
                                }
                            } label: {
                                Text(editMode?.wrappedValue.isEditing == true ? "done" : "select")
                            }

                            TasksTabMoreButton().environment(\.editMode, editMode)
                              
                        }
                        .transaction { t in
                            t.animation = nil
                        }
                    }
                }
                .sheet(isPresented: $taskAddSheet) {
                    TaskEditView(mode: .add)
                }
                
                .navigationTitle("tasks")
        }
        .environmentObject(filters)
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
