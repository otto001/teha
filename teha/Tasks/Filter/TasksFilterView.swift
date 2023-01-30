//
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
        Section {
            Picker("", selection: $filters.taskState) {
                ForEach(TasksFilterViewModel.TaskStateFilter.allCases) { stateFilter in
                    Text(stateFilter.name)
                }
            }
            .listRowInsets(EdgeInsets())
            .pickerStyle(.segmented)
        } header: {
            Text("tasks-filter")
                .font(.headline)
                .foregroundColor(.label)
                .textCase(.none)
        }
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

/**
 A SwiftUI view that allows the user to filter tasks based on an date interval. It will return all upcoming tasks in the specified date interval.
 
 The view displays a picker for selecting the type of date filter and date pickers for selecting the start and end dates of the custom date interval. The view is bound to an `EnvironmentObject` that holds the state of the filter view.
 
 - Parameters:
    - enabledSection: A boolean indicating if the date filter section should be displayed in the active filter section or the non-active filter section. If `true`, the view will be displayed in the active filter section. If `false`, the view will be displayed in the non-active filter section.
    - filters: An `EnvironmentObject` of type `TasksFilterViewModel` that holds the state of the filter view.
*/
fileprivate struct UpcomingFilter: View{
    @EnvironmentObject var filters: TasksFilterViewModel
    let enabledSection: Bool
    
    // A computed property that returns a boolean indicating if the section should be displayed
    var visible: Bool {
        enabledSection == (filters.dateFilterMode != .disabled)
    }
    
    // A binding, needed to set the start of the date interval to the beginning of the selected day
    var startBinding: Binding<Date> {
        Binding {
            return filters.upcomingInterval.start
        } set: { newValue in
            filters.upcomingInterval.start = Calendar.current.startOfDay(for: newValue)
        }
    }
    
    // A binding, needed to set the end of the date interval to the end of the selected day
    var endBinding: Binding<Date> {
        Binding {
            return filters.upcomingInterval.end - TimeInterval.day
        } set: { newValue in
            filters.upcomingInterval.end = Calendar.current.startOfDay(for: newValue) + TimeInterval.day
        }
    }
    
    
    var body: some View{
        if visible {
            VStack {
                Picker(selection: $filters.dateFilterMode) {
                    Text("disabled").tag(TasksFilterViewModel.DateFilterMode.disabled)
                    Divider()
                    Text("match-today").tag(TasksFilterViewModel.DateFilterMode.matchToday)
                    Text("match-this-week").tag(TasksFilterViewModel.DateFilterMode.matchThisWeek)
                    Text("custom").tag(TasksFilterViewModel.DateFilterMode.custom)
                } label: {
                    Label(LocalizedStringKey("upcoming"), systemImage: "calendar.day.timeline.left")
                }
                
                if enabledSection, filters.dateFilterMode == .custom {
                    // A date picker for selecting the start date
                    DatePicker(LocalizedStringKey("from:"), selection: startBinding, displayedComponents: [.date])
                    // A date picker for selecting the end date
                    DatePicker(LocalizedStringKey("to:"), selection: endBinding, in: startBinding.wrappedValue..., displayedComponents: [.date])
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

/**
 A SwiftUI view that allows the user to filter tasks based on an deadline date interval. It will return all tasks which deadline lays  in the specified date interval.
 
 The view displays a picker for selecting the type of date filter and date pickers for selecting the start and end dates of the custom date interval. The view is bound to an `EnvironmentObject` that holds the state of the filter view.
 
 - Parameters:
    - enabledSection: A boolean indicating if the date filter section should be displayed in the active filter section or the non-active filter section. If `true`, the view will be displayed in the active filter section. If `false`, the view will be displayed in the non-active filter section.
    - filters: An `EnvironmentObject` of type `TasksFilterViewModel` that holds the state of the filter view.
*/
fileprivate struct DeadlineFilter: View{
    @EnvironmentObject var filters: TasksFilterViewModel
    let enabledSection: Bool
    
    // A computed property that returns a boolean indicating if the section should be displayed
    var visible: Bool {
        enabledSection == (filters.deadlineFilterMode != .disabled)
    }
    
    // A binding, needed to set the start of the date interval to the beginning of the selected day
    var startBinding: Binding<Date> {
        Binding {
            return filters.deadlineInterval.start
        } set: { newValue in
            filters.deadlineInterval.start = Calendar.current.startOfDay(for: newValue)
        }
    }
    
    // A binding, needed to set the end of the date interval to the end of the selected day
    var endBinding: Binding<Date> {
        Binding {
            return filters.deadlineInterval.end - TimeInterval.day
        } set: { newValue in
            filters.deadlineInterval.end = Calendar.current.startOfDay(for: newValue) + TimeInterval.day
        }
    }
    
    
    var body: some View{
        if visible {
            VStack {
                Picker(selection: $filters.deadlineFilterMode) {
                    Text("disabled").tag(TasksFilterViewModel.DateFilterMode.disabled)
                    Divider()
                    Text("match-today").tag(TasksFilterViewModel.DateFilterMode.matchToday)
                    Text("match-this-week").tag(TasksFilterViewModel.DateFilterMode.matchThisWeek)
                    Text("custom").tag(TasksFilterViewModel.DateFilterMode.custom)
                } label: {
                    Label(LocalizedStringKey("deadline"), systemImage: "calendar.badge.exclamationmark")
                }
                
                if enabledSection, filters.deadlineFilterMode == .custom {
                    // A date picker for selecting the start date
                    DatePicker(LocalizedStringKey("from:"), selection: startBinding, displayedComponents: [.date])
                    // A date picker for selecting the end date
                    DatePicker(LocalizedStringKey("to:"), selection: endBinding, in: startBinding.wrappedValue..., displayedComponents: [.date])
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
    
    @ViewBuilder func priorityPicker(enabledSection: Bool) -> some View {
        if enabledSection == (filters.priority != nil) {
            PriorityPicker( selection: $filters.priority, noneText: "disabled"){
                Label("priority", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
        }
    }
    
    /**
        This function generates a picker view to filter recurring tasks.
        The picker provides two options to select, either "enabled" or "disabled".
        
        - Parameters:
            - enabledSection: A boolean indicating if the date filter section should be displayed in the active filter section or the non-active filter section. If `true`, the view will be displayed in the active filter section. If `false`, the view will be displayed in the non-active filter section.
        - Returns: A picker view for filtering recurring tasks.
    */

    @ViewBuilder func recurringTaskPicker(enabledSection: Bool) -> some View {
        if enabledSection == (filters.recurringTask) {
            Picker(selection: $filters.recurringTask) {
                Text("disabled").tag(false)
                Text("enabled").tag(true)
            } label: {
                Label(LocalizedStringKey("repetitions-only"), systemImage: "repeat")
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
                UpcomingFilter(enabledSection: true)
                DeadlineFilter(enabledSection: true)
                projectPicker(enabledSection: true)
                priorityPicker(enabledSection: true)
                TagFilter(enabledSection: true)
                recurringTaskPicker(enabledSection: true)
                
                // Turns all filters off
                Button(action: {
                    filters.dateFilterMode = .disabled
                    filters.deadlineFilterMode = .disabled
                    filters.project = nil
                    filters.priority = nil
                    filters.tagFilterMode = .disabled
                    filters.recurringTask = false
                }) {
                    Text("reset-all-filters")
                        .foregroundColor(.red)
                }
            } header: {
                sectionTitle("enabled-filters")
            }
        }
        
        
        if !filters.allFiltersActive {
            Section {
                UpcomingFilter(enabledSection: false)
                DeadlineFilter(enabledSection: false)
                projectPicker(enabledSection: false)
                priorityPicker(enabledSection: false)
                TagFilter(enabledSection: false)
                recurringTaskPicker(enabledSection: false)
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

