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
                    TextField(LocalizedStringKey("title"), text: $data.title)
                }

                Section {
                    OptionalDatePicker("earliest-startdate",
                                       addText: "earliest-startdate-add",
                                       selection: $data.earliestStartDate)
                    OptionalDatePicker("deadline",
                                       addText: "deadline-add",
                                       selection: $data.targetCompletionDate)
                }

                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $data.notes)
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
