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
//all items ausgewählt wenn option = nil
fileprivate struct OnlyShow: View {
    
    
    
    @EnvironmentObject var filters: TasksFilterViewModel
    //Array to determin what filter options should be displayed
    
    let options: [TasksFilterOption] = [.init(title: "Project", symbol: "list.clipboard"),
                                        .init(title: "Tag", symbol: "tag"),
                                        .init(title: "Priority", symbol: "text.line.first.and.arrowtriangle.forward"),
                                        .init(title: "Repeating", symbol: "repeat")]
    
    var body: some View {
        Section(header: Text("Only Show")
            .font(.headline)
            .foregroundColor(.black)
        ){
                            //iterating through array of filteroptions
            ProjectPicker(selection: $filters.project){
                Label("project", systemImage: "list.clipboard")
            }
            PriorityPicker( selection: $filters.priority){
                Label("Priority", systemImage: "text.line.first.and.arrowtriangle.forward")
            }

            
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

