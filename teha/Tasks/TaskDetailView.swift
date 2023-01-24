//
//  TaskDetailView.swift
//  teha
//
//  Created by Matteo Ludwig on 12.01.23.
//

import SwiftUI

fileprivate var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

fileprivate var dateFormatterRelative: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

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

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: THTask
    
    @State private var editSheet: Bool = false
    @State private var showNavigationBarTitle: Bool = false
    @State private var hasShownNavigationBarTitle: Bool = false
    
    var canStart: Bool {
        task.startDate == nil && task.completionDate == nil
    }
    
    var canComplete: Bool {
        task.completionDate == nil
    }
    
    var navigationBarTitle: String {
        task.title ?? ""
    }
    
    @ViewBuilder func titleSection(geo: GeometryProxy) -> some View {
        Section {
            
        } header: {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title ?? "")
                    .font(.title2)
                    .fontWeight(.medium)
                    
                    .foregroundColor(.label)
                    .background {
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
                
                if let completionDate = task.completionDate {
                    Text("\(String(localized: "completed")): \(dateFormatterRelative.string(from: completionDate))")
                } else if let earliestStartDate = task.earliestStartDate,
                   !(task.deadline != nil && earliestStartDate <= .now),
                   task.startDate == nil && task.completionDate == nil {
                    Text("\(String(localized: "earliest-startdate")): \(dateFormatterRelative.string(from: earliestStartDate))")
                } else if let deadline = task.deadline, task.completionDate == nil {
                    Text("\(String(localized: "deadline")): \(dateFormatterRelative.string(from: deadline))")
                }
                
            }
            .textCase(.none)
            .listRowInsets(EdgeInsets())
            .padding(.horizontal, 6)
        }
        .padding(.bottom, -16)
    }
    
    @ViewBuilder var progressBar: some View {
        Section {
        } header: {
            TaskProgressBar(task: task)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 6)
                .textCase(.none)
        }
        .padding(.top, 28)
        .padding(.bottom, -16)
    }
    
    @ViewBuilder var projectSection: some View {
        if let project = task.project {
            Section {
                LabeledContent("project") {
                    ProjectLabel(project: project)
                }
                
                LabeledContent("priority") {
                    Text(project.priority.name)
                }
            }
        }
    }
    
    @ViewBuilder var datesSection: some View {
        if task.earliestStartDate != nil || task.deadline != nil {
            Section {
                DateRow(title: "earliest-startdate", date: task.earliestStartDate) { date in
                    return date <= .now ? .green : .label
                }
                DateRow(title: "deadline", date: task.deadline) { date in
                    return date < .now ? .red : .label
                }
            }
        }
    }
    
    @ViewBuilder var reminderSection: some View {
        if let reminder = task.reminderOffset {
            Section {
                LabeledContent("reminder") {
                    Text(reminder.name)
                }
                
                if let reminderSecond = task.reminderOffsetSecond {
                    LabeledContent("reminder-second") {
                        Text(reminderSecond.name)
                    }
                }
                
            }
        }
        
    }
    
    @ViewBuilder var notesSection: some View {
        if let notes = task.notes, !notes.isEmpty {
            Section {
                Text(notes)
            }
        }
    }
    
    @ViewBuilder var tagsSection: some View {
        if let tags = task.tags as? Set<THTag>, !tags.isEmpty {
            Section {
                TagCollection("tags", tags: tags)
            }
        }
    }
    
    var body: some View {
        
        GeometryReader { geo in
            List {
                titleSection(geo: geo)
                progressBar
                projectSection
                datesSection
                reminderSection
                notesSection
                tagsSection
            }
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editSheet = true
                } label: {
                    Text("Edit")
                }
                
            }
        }
        .sheet(isPresented: $editSheet) {
            TaskEditView(mode: .edit(task))
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var task: THTask {
        let task = try! PersistenceController.preview.container.viewContext.fetch(THTask.all).first!
        
        task.title = "Super important Task with kinda long title that goes on forever and is really just pointless"
        
        task.earliestStartDate = DateComponents(calendar: .current, year: 2022, month: 12, day: 28).date!
        task.deadline = DateComponents(calendar: .current, year: 2023, month: 1, day: 24, hour: 23, minute: 59).date!
        task.reminderOffset = ReminderOffset(rawValue: 10)
        task.reminderOffsetSecond = ReminderOffset(rawValue: 30)
        task.notes = "This Task is super important, DO NOT FORGET!\nAlso call Janet."
        return task
    }
    
    static var previews: some View {
        
        
        NavigationStack {
            TaskDetailView(task: TaskDetailView_Previews.task)
        }
    }
}
