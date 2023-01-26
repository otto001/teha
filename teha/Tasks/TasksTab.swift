//
//  TasksTab.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//


import SwiftUI

fileprivate struct TasksTabFiltersActiveButton: View {
    @Environment(\.editMode) var editMode
    
    @Binding var filterSheet: Bool
    
    let filtersAreActive: Bool
    
    var body: some View {
        if filtersAreActive {
            Button {
                filterSheet = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
            }
            .disabled(editMode?.wrappedValue == .active )
        }
    }
}

fileprivate struct TasksTabMoreButton: View {
    @Environment(\.editMode) var editMode
    
    @Binding var groupSheet: Bool
    @Binding var filterSheet: Bool
    
    let filtersAreActive: Bool
    
    var filterSystemImage: String {
        filtersAreActive ?
        "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
    
    var body: some View {
        if editMode?.wrappedValue != .active {
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
}

struct TasksTab: View {
    @Environment(\.editMode) var editMode
    
    @State var taskAddSheet: Bool = false
    @State var filterSheet: Bool = false
    @State var groupSheet: Bool = false
    
    @StateObject var filters = TasksFilterViewModel()
    
    
    var filtersAreActive: Bool {
        return filters.anyFilterActive
    }
    
    var body: some View {
        NavigationStack {
            TasksListView()
                .environment(\.editMode, editMode)
                .environmentObject(filters)
                .navigationDestination(for: THTask.self) { task in
                    TaskDetailView(task: task)
                }
                .searchable(text: $filters.search)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            taskAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            
                            TasksTabFiltersActiveButton(filterSheet: $filterSheet, filtersAreActive: filtersAreActive)
                            
                            Button {
                                withAnimation {
                                    editMode?.wrappedValue = (editMode?.wrappedValue.isEditing == true ? EditMode.inactive : EditMode.active)
                                }
                            } label: {
                                Text(editMode?.wrappedValue.isEditing == true ? "done" : "select")
                            }

                            TasksTabMoreButton(groupSheet: $groupSheet, filterSheet: $filterSheet, filtersAreActive: filtersAreActive)
                        }
                        .transaction { t in
                            t.animation = nil
                        }
                    }
                }
                .sheet(isPresented: $filterSheet) {
                    TasksFilterView().environmentObject(filters)
                }
                .sheet(isPresented: $taskAddSheet) {
                    TaskEditView(mode: .add)
                }
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
