//
//  TasksFilter.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TasksFilterView: View {
    let close: () ->  Void
    
    var body: some View {
        NavigationStack {
            VStack{
                ListView()
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
}

struct ListView: View {
    var body: some View {
        VStack{
            Form {
                CheckmarkGroup()
            }
        }
    

    }
    struct CheckmarkGroup: View {
        @State private var selectedIndex = -1
        //Array to determin what filter options should be displayed
        let filterOptions = ["Project", "Tag", "Priority", "Repeating"]
        let symbols = ["list.clipboard", "tag", "text.line.first.and.arrowtriangle.forward", "repeat"]

        var body: some View {
            Section(header: Text("Only Show")
                .font(.headline)
                .foregroundColor(.black)
            ){
                Group{
                    //iterating through array of filteroptions
                    //to create for every item in there a button
                    ForEach(0..<filterOptions.count) { index in
                        Button(action: {
                            //make the buttons 'detect' if they were clicked or not
                            if self.selectedIndex == index {
                                self.selectedIndex = -1
                            } else {
                                self.selectedIndex = index
                            }
                        }) {
                            HStack {
                                //adding the symbol on the left per filterOption
                                Image(systemName: self.symbols[index])
                                    .foregroundColor(.blue)
                                Text(self.filterOptions[index])
                                    .foregroundColor(.black)
                                Spacer()
                                //makes sure, only one filteroptions is selected at a time
                                if self.selectedIndex == index {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    
//    struct CheckmarkRow: View {
//        let item: String
//        let symbol: String
//        @State private var isChecked = false
//
//        var body: some View {
//            Button(action: {
//                self.isChecked.toggle()
//            }) {
//                HStack {
//                    Image(systemName: symbol)
//                        .foregroundColor(.blue)
//                    Text(item)
//                        .foregroundColor(.black)
//                    Spacer()
//                    if isChecked {
//                        Image(systemName: "checkmark")
//                    }
//                }
//            }
//        }
//    }
    
    
    struct TasksrView_Previews: PreviewProvider {
        static var previews: some View {
            TasksFilterView() {
                
            }
        }
    }
}
