//
//  TasksFilter.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksFilterOption: Identifiable, Equatable {
    var title: LocalizedStringKey { LocalizedStringKey(id) }
    let symbol: String
    let id: String
    
    init(title: String, symbol: String) {
        self.symbol = symbol
        self.id = title
    }
}

struct TasksFilterView: View {
    let close: () ->  Void
    var body: some View {
        NavigationStack {
            Form {
                OnlyShow()
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        close()
                    } label: {
                        Text("done").fontWeight(.semibold)
                    }
                    
                }
            }
            .navigationTitle("filter")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        
        
    }
}


fileprivate struct TagFilter: View{
    @EnvironmentObject var filters: TasksFilterViewModel
    let enabledSection: Bool
    var body: some View{
        if enabledSection && filters.tagFilterMode != .disabled || !enabledSection && filters.tagFilterMode == .disabled{
            VStack{
                Picker(selection: $filters.tagFilterMode) {
                    Text("disabled").tag(TasksFilterViewModel.TagFilterMode.disabled)
                    Text("match-any").tag(TasksFilterViewModel.TagFilterMode.matchAny)
                    Text("match-all").tag(TasksFilterViewModel.TagFilterMode.matchAll)
                } label: {
                    Label(LocalizedStringKey("tag"), systemImage: "tag")
                    
                }
                
                if enabledSection{
                    TagPicker(selection: $filters.tags)
                }
            }
        }
    }
}





//all items ausgewählt wenn option = nil
fileprivate struct OnlyShow: View {
    
    
    
    @EnvironmentObject var filters: TasksFilterViewModel
    //Array to determin what filter options should be displayed
    
    let options: [TasksFilterOption] = [.init(title: "Project", symbol: "list.clipboard"),
                                        .init(title: "Tag", symbol: "tag"),
                                        .init(title: "Priority", symbol: "text.line.first.and.arrowtriangle.forward"),
                                        .init(title: "Repeating", symbol: "repeat")]
    
    @ViewBuilder func projectPicker(enabledSection: Bool) -> some View {
        if enabledSection && filters.project != nil || !enabledSection && filters.project == nil{
            ProjectPicker(selection: $filters.project){
                Label("project", systemImage: "list.clipboard")
            }
        }
        
    }
    
    @ViewBuilder func priorityPicker(enabledSection: Bool) -> some View{
        if enabledSection && filters.priority != nil || !enabledSection && filters.priority == nil{
            PriorityPicker( selection: $filters.priority){
                Label("Priority", systemImage: "text.line.first.and.arrowtriangle.forward")
            }
        }
        
    }
    
    var body: some View {
        Section{ //TODO: Animation hinzufügen
                projectPicker(enabledSection: true)
                priorityPicker(enabledSection: true)
                TagFilter(enabledSection: true)
        } header: {
            Text("Enabled")
                .font(.headline)
                .foregroundColor(.label)
                .textCase(.none)
        }
        Section(header: Text("Only Show")
            .font(.headline)
            .foregroundColor(.label)
            .textCase(.none)
        ){
                            //iterating through array of filteroptions
                projectPicker(enabledSection: false)
                priorityPicker(enabledSection: false)
                TagFilter(enabledSection: false)
                
            

            
            //to create for every item in there a button
            
            
            
//                ForEach(options) { option in
//                    Button(action: {
//                        //make the buttons 'detect' if they were clicked or not
////                        if self.selected == option {
////                            self.selected = nil
////                        } else {
////                            self.selected = option
////                        }
//                    }) {
//                        HStack {
//                            //adding the symbol on the left per filterOption
//                            Image(systemName: option.symbol)
//                                .foregroundColor(.blue)
//                            Text(option.title)
//                                .foregroundColor(.black)
//                            Spacer()
//                            //makes sure, only one filteroptions is selected at a time
////                            if self.selected == option {
////                                Image(systemName: "checkmark")
////                            }
//                        }
//                    }
//                }
        }
    }
}

struct TasksrView_Previews: PreviewProvider {
    static var previews: some View {
        TasksFilterView() {

        }.environmentObject(TasksFilterViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

