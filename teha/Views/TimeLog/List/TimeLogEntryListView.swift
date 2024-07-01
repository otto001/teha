//
//  TimeLogEntryListView.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//

import SwiftUI

fileprivate let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

struct TimeLogEntryListView: View {
    @SectionedFetchRequest(fetchRequest: THTimeLogEntry.all, sectionIdentifier: \.monthString) var sections: SectionedFetchResults<String, THTimeLogEntry>
    
    func header(for id: String) -> String {
        if id.count == 7 {
            // id is of format [year]-[month]
            let year = Int(id.substring(start: 0, end: 4))!
            let month = Int(id.suffix(from: id.index(offsetFromStart: 5)))!
            return "\(dateFormatter.monthSymbols[month-1]), \(year)"
        }
        return ""
    }
    
    var body: some View {
        List {
            ForEach(sections) { section in
                
                Section {
                    ForEach(section) { logEntry in
                        TimeLogEntryListRowView(logEntry: logEntry)
                    }
                } header: {
                    Text(header(for: section.id))
                }
            }
        }
    }
}

#Preview {
    TimeLogEntryListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
