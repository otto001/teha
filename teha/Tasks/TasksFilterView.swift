//
//  TasksFilter.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                CompletionPicker()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                Filters()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("done").fontWeight(.semibold)
                    }
                    
                }
            }
            .navigationTitle("filter")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}


fileprivate struct CompletionPicker: View {
    @EnvironmentObject var filters: TasksFilterViewModel
    
    var body: some View {
        Picker("", selection: $filters.taskState) {
            ForEach(TasksFilterViewModel.TaskStateFilter.allCases) { stateFilter in
                Text(stateFilter.name)
            }
        }
        .pickerStyle(.segmented)
    }
}

fileprivate struct TagFilter: View{
    @EnvironmentObject var filters: TasksFilterViewModel
    let enabledSection: Bool
    
    var visible: Bool {
        enabledSection == (filters.tagFilterMode != .disabled)
    }
    
    var body: some View{
        if visible {
            VStack {
                Picker(selection: $filters.tagFilterMode) {
                    Text("disabled").tag(TasksFilterViewModel.TagFilterMode.disabled)
                    Divider()
                    Text("match-any-tag").tag(TasksFilterViewModel.TagFilterMode.matchAny)
                    Text("match-all-tags").tag(TasksFilterViewModel.TagFilterMode.matchAll)
                } label: {
                    Label(LocalizedStringKey("tags"), systemImage: "tag")
                }
                
                if enabledSection{
                    TagPicker(selection: $filters.tags, compact: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

//all items ausgewählt wenn option = nil
fileprivate struct Filters: View {

    @EnvironmentObject var filters: TasksFilterViewModel

    
    @ViewBuilder func projectPicker(enabledSection: Bool) -> some View {
        if enabledSection == (filters.project != nil) {
            ProjectPicker(selection: $filters.project, noneText: "disabled"){
                Label("project", systemImage: "briefcase")
            }
        }
        
    }
    
    @ViewBuilder func priorityPicker(enabledSection: Bool) -> some View{
        if enabledSection == (filters.priority != nil) {
            PriorityPicker( selection: $filters.priority, noneText: "disabled"){
                Label("Priority", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
        }
        
    }
    
    @ViewBuilder func sectionTitle(_ titleKey: LocalizedStringKey) -> some View {
        Text(titleKey)
            .font(.headline)
            .foregroundColor(.label)
            .textCase(.none)
    }
    
    var body: some View {
        if filters.anyFilterActive {
            Section { //TODO: Animation hinzufügen
                projectPicker(enabledSection: true)
                priorityPicker(enabledSection: true)
                TagFilter(enabledSection: true)
            } header: {
                sectionTitle("enabled-filters")
            }
        }
        
        
        if !filters.allFiltersActive {
            Section {
                projectPicker(enabledSection: false)
                priorityPicker(enabledSection: false)
                TagFilter(enabledSection: false)
            } header: {
                sectionTitle("other-filters")
            }
        }
    }
}

struct TasksFilterView_Previews: PreviewProvider {
    static var viewModel: TasksFilterViewModel {
        let viewModel = TasksFilterViewModel()
        viewModel.tagFilterMode = .matchAny
        return viewModel
    }
    
    static var previews: some View {
        TasksFilterView().environmentObject(TasksFilterViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

