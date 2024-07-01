//
//  TimeLogEntryListRowView.swift
//  teha
//
//  Created by Matteo Ludwig on 01.07.24.
//

import SwiftUI

fileprivate var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .none
    formatter.dateStyle = .short
    formatter.formattingContext = .listItem
    return formatter
}()


struct TimeLogEntryListRowView: View {
    let logEntry: THTimeLogEntry
    
    var timeLoggedText: String {
        logEntry.worktime.formattedShort ?? ""
    }
    
    var dateText: String {
        logEntry.date.map { dateFormatter.string(from: $0) } ?? ""
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {

            // Left section: Task Title & Project Name & Color
            VStack(alignment: .leading, spacing: 2) {
                
                Text(logEntry.task?.title ?? "")
                    .lineLimit(2)
                    .fontWeight(.medium)
                
                HStack(spacing: 6) {
                    // Show project label if applicable
                    if let project = logEntry.task?.project {
                        ProjectLabel(project: project)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(timeLoggedText)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(dateText)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(.secondary)
               
            }

        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background {
            // navigationLink to the selected task
            NavigationLink(value: NavigationPage.timeLogEntryDetail(logEntry)) {
                EmptyView()
            }.opacity(0)
        }
        .frame(minHeight: 36)
    }
}

struct TimeLogEntryListRowView_Previews: PreviewProvider {
    
    private struct TimeLogEntryListRowViewPeview: View {
        @FetchRequest(fetchRequest: THTimeLogEntry.all) var results: FetchedResults<THTimeLogEntry>
        var body: some View {
            List(results) { logEntry in
                TimeLogEntryListRowView(logEntry: logEntry)
            }
        }
    }
    
    static var previews: some View {
        TimeLogEntryListRowViewPeview().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
