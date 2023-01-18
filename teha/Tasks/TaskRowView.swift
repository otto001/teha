//
//  TaskRowView.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

// The formatter used in TaskRowView for the remining time until deadline
fileprivate var timeRemainingFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    formatter.dateTimeStyle = .named
    formatter.formattingContext = .listItem
    return formatter
}()


struct TaskRowView: View {
    @ObservedObject var task: THTask
    
    @EnvironmentObject var router: Router
    
    /// The content of the text right above the progress bar.
    /// Shows time remaining until deadline or the time passed since the deadline (if a deadline is set)
    var timeRemainingText: String? {
        guard !task.isCompleted else { return nil }
        if let deadline = task.deadline {
            let now: Date = .now
            return timeRemainingFormatter.localizedString(for: deadline, relativeTo: now)
        }
        return nil
    }
    
    /// The color of the text right above the progress bar
    var timeRemainingColor: Color {
        if let deadline = task.deadline {
            return deadline < .now - .minute ? .red : .secondaryLabel
        }
        return .secondaryLabel
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {

            // Left section: Task Title & Project Name & Color
            VStack(alignment: .leading, spacing: 2) {
                
                Text(task.title ?? "")
                    .lineLimit(2)
                    .strikethrough(task.isCompleted)
                    .fontWeight(.medium)
                
                // Show project label if applicable
                if let project = task.project {
                    ProjectLabel(project: project)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)
                }
            }
            
            Spacer()
            
            // Right section: Deadline (if applicable) & Task progress
            VStack(alignment: .trailing, spacing: 2) {
                // Show time remaining before deadline if applicable
                if let timeRemainingText = timeRemainingText {
                    Text(timeRemainingText)
                        .lineLimit(1)
                        .font(.caption2)
                        .foregroundColor(timeRemainingColor)
                }
                
                // small, gray TaskProgressBar
                TaskProgressBar(task: task,
                                activeColor: .secondaryLabel,
                                inactiveColor: .systemFill)
                .frame(width: 80, height: 5)
                
                // If we show text above the progress bar, we need to add text of the same size as the deadline text below the progress bar for spacing reasons.
                // Unfortnately, we were unable to solve this alignment issue with alignment guides only, therefore we use a transparent text as a work-around
                if timeRemainingText != nil {
                    Text("1")
                        .font(.caption2)
                        .opacity(0)
                }
                
            }

        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background {
            NavigationLink(value: task) {
                EmptyView()
            }.opacity(0)
        }
        .frame(minHeight: 36)
    }
}

struct TaskRowView_Previews: PreviewProvider {
    
    private struct TaskRowViewPreview: View {
        @FetchRequest(fetchRequest: THTask.all) var results: FetchedResults<THTask>
        var body: some View {
            List(results) { task in
                TaskRowView(task: task)
            }
        }
    }
    
    static var previews: some View {
        TaskRowViewPreview().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
