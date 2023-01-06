//
//  TaskEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI

 

struct TaskEditView: View {
    @State var data = Data()

    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $data.title)
                }

                Section {
                    OptionalDatePicker("Earliest Startdate", selection: $data.earliestStartDate)
                    OptionalDatePicker("Deadline", selection: $data.targetCompletionDate)
                }
                
                
                Section {
                    TextFieldMultiline("Notes", text: $data.notes)
                        .frame(minHeight: 72)
                }
            }
        }
    }
}

extension TaskEditView {
    struct Data {
        var title: String = ""
        var notes: String = ""
        var earliestStartDate: Date? = nil
        var targetCompletionDate: Date? = Date.now
        var timeEstimate: Double? = nil
        
        var test: Date = .now
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditView()
    }
}
