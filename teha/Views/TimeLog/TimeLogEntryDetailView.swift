//
//  TimeLogEntryDetailView.swift
//  teha
//
//  Created by Matteo Ludwig on 02.07.24.
//

import SwiftUI

fileprivate var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .short
    formatter.formattingContext = .listItem
    return formatter
}()

struct TimeLogEntryDetailView: View {
    let timeLogEntry: THTimeLogEntry
    
    @State private var editSheet: Bool = false
    
    var body: some View {
        List {
            
        }.navigationTitle("\(timeLogEntry.task?.taskDescription?.title ?? "") - \(timeLogEntry.date.map {dateFormatter.string(from: $0)} ?? "")")
        .toolbar {
            // place button for the TaskEditView
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editSheet = true
                } label: {
                    Text("edit")
                }
                
            }
        }
        // Show the taskEditsheet
        .sheet(isPresented: $editSheet) {
            TimeLogEntryEditView(.edit(timeLogEntry))
        }
    }
}

//#Preview {
//    TimeLogEntryDetailView()
//}
