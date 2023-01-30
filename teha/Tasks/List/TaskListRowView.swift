//
//  TaskListRowView.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

// The formatter used in TaskListRowView for the remining time until deadline
fileprivate var timeRemainingFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    formatter.dateTimeStyle = .named
    formatter.formattingContext = .listItem
    return formatter
}()



struct TaskListRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: THTask
    let now: Date
    
    @State var showDeleteDialog: Bool = false

    /// The content of the text right above the progress bar.
    /// Shows time remaining until deadline or the time passed since the deadline (if a deadline is set)
    var timeRemainingText: String? {
        guard !task.isCompleted else { return nil }
        
        if let deadline = task.deadline {
            let timeString = timeRemainingFormatter.localizedString(for: deadline, relativeTo: now)
            return "\(String(localized: "deadline")) \(timeString)"
        }
        return nil
    }
    
    /// The color of the text right above the progress bar
    var timeRemainingColor: Color {
        if !task.isCompleted, let deadline = task.deadline {
            
            if deadline < now {
                return .red
            } else if task.estimatedWorktimeRemaining != .zero  {
                let absoluteLatestStartDate = Calendar.current.date(byAdding: .minute, value: -task.estimatedWorktimeRemaining.totalMinutes, to: deadline)!
                if absoluteLatestStartDate <= now {
                    return .orange
                }
            }
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
                
                HStack(spacing: 6) {
                    // Show project label if applicable
                    if let project = task.project {
                        ProjectLabel(project: project)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.secondaryLabel)
                    }
                    
                    if task.isRepeating {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .scaleEffect(0.75)
                            .padding(.leading, 2)
                        
                    }
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
        
        .swipeActions(edge: .trailing) {
            Button {
                showDeleteDialog = true
            } label: {
                Label("delete", systemImage: "trash")
            }
            .tint(Color.red)
        }
        .confirmationDialog("task-delete-confirmation", isPresented: $showDeleteDialog) {
            let hasFutureSiblings = task.hasFutureSiblings()
            if hasFutureSiblings {
                Button("repeating-delete-future", role: .destructive) {
                    // Remove all pending reminders for task
                    NotificationManager.instance.cancelPendingNotifications(for: task)
                    
                    task.deleteFutureRepeatSiblings(context: viewContext)
                    viewContext.delete(task)
                    // TODO: error handling
                    try? viewContext.save()
                }
            }
            Button(hasFutureSiblings ? "repeating-delete-only-self" : "delete", role: .destructive) {
                // Remove all pending reminders for task
                NotificationManager.instance.cancelPendingNotifications(for: task)
                
                viewContext.delete(task)
                // TODO: error handling
                try? viewContext.save()
            }
        } message: {
            Text(task.hasFutureSiblings() ? "repeating-delete-prompt" : "task-delete-confirmation")
        }
    }
}

struct TaskListRowView_Previews: PreviewProvider {
    
    private struct TaskListRowViewPreview: View {
        @FetchRequest(fetchRequest: THTask.all) var results: FetchedResults<THTask>
        var body: some View {
            List(results) { task in
                TaskListRowView(task: task, now: .now)
            }
        }
    }
    
    static var previews: some View {
        TaskListRowViewPreview().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
