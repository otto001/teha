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

fileprivate struct DateRow: View {
    let title: LocalizedStringKey
    let date: Date?
    
    var body: some View {
        if let date = date {
            LabeledContent(title) {
                Text(dateFormatter.string(from: date))
                    .fixedSize()
                    .foregroundColor(.label)
            }
        }
    }
}

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: THTask
    
    @State private var editSheet: Bool = false
    @State private var showNavigationBarTitle: Bool = false
    
    @ViewBuilder func titleSection(geo: GeometryProxy) -> some View {
        Section {
            
        } header: {
            Text(task.title ?? "")
                .font(.title2)
                .fontWeight(.medium)
                .textCase(.none)
                .listRowInsets(EdgeInsets())
                .foregroundColor(.label)
                .background {
                    GeometryReader { titleGeometry in
                        let titleY = titleGeometry.frame(in: .global).maxY
                        Color.clear
                            .onChange(of: titleY) { newValue in
                                self.showNavigationBarTitle = newValue < geo.safeAreaInsets.top
                            }
                    }
                }
            
                .padding(.horizontal, 6)
        }
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
                DateRow(title: "earliest-startdate", date: task.earliestStartDate)
                DateRow(title: "deadline", date: task.deadline)
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
    
    var body: some View {
        
        GeometryReader { geo in
            List {
                titleSection(geo: geo)
                projectSection
                datesSection
                notesSection
            }
        }
        .navigationTitle(self.showNavigationBarTitle ? task.title ?? "" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        return task
    }
    
    static var previews: some View {
        
        
        NavigationStack {
            TaskDetailView(task: TaskDetailView_Previews.task)
        }
    }
}
