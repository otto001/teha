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
            ZStack {
                
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

struct TasksFilterView_Previews: PreviewProvider {
    static var previews: some View {
        TasksFilterView() {
            
        }
    }
}
