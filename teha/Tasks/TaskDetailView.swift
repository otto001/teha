//
//  TaskDetailView.swift
//  teha
//
//  Created by Matteo Ludwig on 12.01.23.
//

import SwiftUI

/// DateFormatter used for standard date formatting
fileprivate var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

/// DateFormatter used for relative date formatting, e.g. yesterday, in 2 weeks...
fileprivate var dateFormatterRelative: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

/// A Row of a view containing a date formatted by the standard DateFormatter
fileprivate struct DateRow: View {
    let title: LocalizedStringKey
    let date: Date?
    let color: (_ date: Date) -> Color
    
    var body: some View {
        if let date = date {
            LabeledContent(title) {
                Text(dateFormatter.string(from: date))
                    .fixedSize()
                    .foregroundColor(color(date))
            }
        }
    }
}

///
struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // The currently shown THTask
    @ObservedObject var task: THTask

    // variable that is true if the editSheet is currently used
    @State private var editSheet: Bool = false
    @State private var showNavigationBarTitle: Bool = false
    @State private var hasShownNavigationBarTitle: Bool = false

    // Is true if the user can Start the task, when startDate and completionDate are nil
    var canStart: Bool {
        task.startDate == nil && task.completionDate == nil
    }

    // Is true if a user can complete a task, when the completionDate is nil
    var canComplete: Bool {
        task.completionDate == nil
    }

    // The navigationBarTitle of the view. returns the title of the current task or an empty string if there is no title
    var navigationBarTitle: String {
        task.title ?? ""
    }


    var subtitle: String? {
        // returns the relative time to the completionDate as a string if one exists
        if let completionDate = task.completionDate {
            return "\(String(localized: "completed")): \(dateFormatterRelative.string(from: completionDate))"

        // Returns the relative time to the earliestStartDate if one exists, and a deadline exists, the earliestStartDate
        // is bigger than .now, and the startDate is nil and the completionDate is nil
        } else if let earliestStartDate = task.earliestStartDate,
           !(task.deadlineDate != nil && earliestStartDate <= .now),
           task.startDate == nil && task.completionDate == nil {
            
            return "\(String(localized: "earliest-startdate")): \(dateFormatterRelative.string(from: earliestStartDate))"

        // Returns the relative time to the deadline, if one exists and the completionDate is nil
        } else if let deadline = task.deadlineDate, task.completionDate == nil {
            
            return "\(String(localized: "deadline")): \(dateFormatterRelative.string(from: deadline))"
            
        }
        // return empty text for spacing reasons (i know, kinda dirty, but this automatically adjusts to dynamic font sizes, which is hard to do otherwise in swift
        return " "
    }


    @ViewBuilder func title(geo: GeometryProxy) -> some View {

        VStack(alignment: .leading, spacing: 6) {
            Text(task.title ?? "")
                .font(.title2)
                .fontWeight(.medium)
                
                .foregroundColor(.label)
                .background {
                    // Read the position of the current title, If it goes out of view show it as the navigationBarTitle
                    // If it goes back into view reset the navigationBarTitle
                    GeometryReader { titleGeometry in
                        let titleY = titleGeometry.frame(in: .global).maxY
                        Color.clear
                            .onChange(of: titleY) { newValue in
                                showNavigationBarTitle = newValue < geo.safeAreaInsets.top
                                if showNavigationBarTitle {
                                    hasShownNavigationBarTitle = true
                                }
                            }
                    }
                }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .foregroundColor(.secondaryLabel)
                    .font(.subheadline)
            }
            
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder var progressBar: some View {
        
        // The teha-style interactive progress bar for reading and setting task progress
        TaskProgressBarInteractive(task: task)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.horizontal, 8)
        .padding(.top, 22)
    }
    
    @ViewBuilder var projectSection: some View {
        // Show the currently assigned project and priority of the task
        Section {
            if let project = task.project {
                LabeledContent("project") {
                    ProjectLabel(project: project)
                }
            }
            
            LabeledContent("priority") {
                Text(task.priority.name)
            }
        }
    }
    
    @ViewBuilder var datesSection: some View {
        // Show a dateRow for earliestStartDate and Deadline if they are not nil
        if task.earliestStartDate != nil || task.deadlineDate != nil {
            Section {
                DateRow(title: "earliest-startdate", date: task.earliestStartDate) { date in
                    return date <= .now ? .green : .label
                }
                DateRow(title: "deadline", date: task.deadlineDate) { date in
                    return date < .now ? .red : .label
                }
            }
        }
    }
    
    @ViewBuilder var reminderSection: some View {
        // Show the reminder of the task if one exists
        if let reminder = task.reminderFirstOffset {
            Section {
                LabeledContent("reminder") {
                    Text(reminder.name)
                }
                // if a second reminder exists also show that reminder
                if let reminderSecond = task.reminderSecondOffset {
                    LabeledContent("reminder-second") {
                        Text(reminderSecond.name)
                    }
                }
                
            }
        }
        
    }
    
    @ViewBuilder var notesSection: some View {
        // Show a multiline Textfield if notes exist
        if let notes = task.taskDescription?.notes, !notes.isEmpty {
            Section {
                Text(notes)
            }
        }
    }
    
    @ViewBuilder var tagsSection: some View {
        // Show a collection of tags if any exist
        if let tags = task.taskDescription?.tags, !tags.isEmpty {
            Section {
                TagCollection("tags", tags: tags)
            }
        }
    }
    
    var body: some View {
        // Geometry Reader to know where the top of the view is currently at, to know the position of the title
        GeometryReader { geo in
            List {
                title(geo: geo)
                progressBar
                
                projectSection
                datesSection
                reminderSection
                
//                if let address = task.address, !address.isEmpty {
//                    HStack {
//                        Image(systemName: "mappin")
//                        Text(address)
//                    }
//                }
                
                notesSection
                tagsSection
            }
            .padding(.top, -20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(hasShownNavigationBarTitle ? navigationBarTitle : "")
                    .lineLimit(1)
                    .opacity(showNavigationBarTitle ? 1 : 0)
                    .animation(.linear(duration: 0.2), value: showNavigationBarTitle)
                    .transition(.opacity)
            }
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
            TaskEditView(mode: .edit(task))
        }
    }
}
//
//struct TaskDetailView_Previews: PreviewProvider {
//    static var task: THTask {
//        let task = try! PersistenceController.preview.container.viewContext.fetch(THTask.all).first!
//        
//        task.title = "Super important Task with kinda long title that goes on forever and is really just pointless"
//        
//        task.earliestStartDate = DateComponents(calendar: .current, year: 2022, month: 12, day: 28).date!
//        task.deadline = DateComponents(calendar: .current, year: 2023, month: 1, day: 24, hour: 23, minute: 59).date!
//        task.reminderOffset = ReminderOffset(rawValue: 10)
//        task.reminderOffsetSecond = ReminderOffset(rawValue: 30)
//        task.notes = "This Task is super important, DO NOT FORGET!\nAlso call Janet."
//        
//        task.startDate = DateComponents(calendar: .current, year: 2022, month: 12, day: 29).date!
//        task.completionProgress = 0.5
//        
//        task.estimatedWorktime = .init(hours: 2, minutes: 20)
//        
//        return task
//    }
//    
//    static var previews: some View {
//        
//        
//        NavigationStack {
//            TaskDetailView(task: TaskDetailView_Previews.task)
//        }
//    }
//}
