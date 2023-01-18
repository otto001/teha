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
    
    var subtitle: String? {
        if let completionDate = task.completionDate {
            return "\(String(localized: "completed")): \(dateFormatterRelative.string(from: completionDate))"
            
        } else if let earliestStartDate = task.earliestStartDate,
           !(task.deadline != nil && earliestStartDate <= .now),
           task.startDate == nil && task.completionDate == nil {
            
            return "\(String(localized: "earliest-startdate")): \(dateFormatterRelative.string(from: earliestStartDate))"
            
        } else if let deadline = task.deadline, task.completionDate == nil {
            
            return "\(String(localized: "deadline")): \(dateFormatterRelative.string(from: deadline))"
            
        }
        return nil
    }
    
    @ViewBuilder func title(geo: GeometryProxy) -> some View {

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
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .foregroundColor(.secondaryLabel)
            }
            
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder var progressBar: some View {
        TaskProgressBarInteractive(task: task)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.horizontal, 8)
            .padding(.top, 22)
    }
    
    @ViewBuilder var projectSection: some View {
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
                title(geo: geo)
                progressBar
                
                projectSection
                datesSection
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
        task.notes = "This Task is super important, DO NOT FORGET!\nAlso call Janet."
        
        task.startDate = DateComponents(calendar: .current, year: 2022, month: 12, day: 29).date!
        task.completionProgress = 0.4
        return task
    }
    
    static var previews: some View {
        
        
        NavigationStack {
            TaskDetailView(task: TaskDetailView_Previews.task)
        }
    }
}
