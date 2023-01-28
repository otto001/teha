//
//  TaskEditView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI



struct TaskEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss: DismissAction
    
   
    @State var data = FormData()
    
    @State var showError: Bool = false
    
    let mode: Mode
    
    var task: THTask? {
        if case let .edit(task) = mode {
            return task
        }
        return nil
    }
    
    var editing: Bool {
        return task != nil
    }
    
    var navigationTitle: String {
        return editing ? data.title : String(localized: "new-task")
    }
    
    var projectPickerBinding: Binding<THProject?> {
        Binding {
            data.project
        } set: { newValue in
            data.project = newValue
            data.priority = newValue?.priority ?? data.priority
        }

    }
    
    func done() {
        guard data.valid else {
            showError = true
            return
        }
        
        let task = task ?? THTask(context: viewContext)
        
        task.title = data.title
        task.notes = data.notes
        task.priority = data.priority
        
        task.earliestStartDate = data.earliestStartDate
        task.deadline = data.deadline
        
        task.estimatedWorktime = data.estimatedWorktime
        
        task.project = data.project
        
        task.tags = data.tags as NSSet
        
        if !editing {
            task.creationDate = Date.now
        }
        
        // TODO: error handling
        try? viewContext.save()
        
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(LocalizedStringKey("title"), text: $data.title)
                    ProjectPicker("project",  selection: projectPickerBinding)
                    PriorityPicker("priority", selection: $data.priority)
                }

                Section {
                    OptionalDatePicker("earliest-startdate",
                                       addText: "earliest-startdate-add",
                                       selection: $data.earliestStartDate)
                    OptionalDatePicker("deadline",
                                       addText: "deadline-add",
                                       selection: $data.deadline)
                } footer: {
                    if data.deadlineBeforeEarliestStartDate {
                        Text(FormError.deadlineBeforeEarliestStartDate.failureReason!)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    WorktimeField(value: $data.estimatedWorktime)
                } footer: {
                    // Show error when estimatedWorktime exceed maximum value.
                    if data.estimatedWorktimeTooHigh {
                        Text(FormError.estimatedWorktimeTooHigh.failureReason!)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $data.notes)
                        .frame(minHeight: 72)
                    TagPicker(selection: $data.tags)
                }
            }
            .formSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: data.valid, done: done) {
                dismiss()
            }
            .alert(isPresented: $showError, error: data.error) { _ in
                Button {
                    showError = false
                } label: {
                    Text("ok")
                }
            } message: { error in
                Text(error.failureReason ?? "")
            }
            .onAppear {
                if let task = task {
                    self.data = .init(task: task)
                }
            }
        }
    }
}

extension TaskEditView {
    enum FormError: LocalizedError {
        case noTitle
        case deadlineBeforeEarliestStartDate
        case estimatedWorktimeTooHigh
        
        var errorDescription: String? {
            String(localized: "cannot-save-task")
        }
        
        var failureReason: String? {
            switch self {
            case .noTitle: return String(localized: "task-must-have-title")
            case .deadlineBeforeEarliestStartDate: return String(localized: "task-deadline-must-be-after-earliest-startdate")
            case .estimatedWorktimeTooHigh:
                return String(localized: "estimated-worktime-too-high") // TODO: LOCALIZE
            }
        }
    }
    
    struct FormData {
        var title: String = ""
        var notes: String = ""
        var priority: Priority = .normal
        
        var earliestStartDate: Date? = nil
        var deadline: Date? = nil
        
        var estimatedWorktime: Worktime = .init(hours: 1, minutes: 0)
        
        var project: THProject?
        
        var tags: Set<THTag> = .init()
        
        /// True when the deadline is before the earliestStartDate.
        var deadlineBeforeEarliestStartDate: Bool {
            if let earliestStartDate = earliestStartDate,
               let deadline = deadline,
               earliestStartDate > deadline {
                return true
            }
            return false
        }
        
        /// True when estimatedWorktime is over 100 hours.
        var estimatedWorktimeTooHigh: Bool {
            return estimatedWorktime > Worktime(hours: 100, minutes: 0)
        }
        
        var error: FormError? {
            if title.isEmpty {
                return .noTitle
            } else if deadlineBeforeEarliestStartDate {
                return .deadlineBeforeEarliestStartDate
            } else if estimatedWorktimeTooHigh {
                return .estimatedWorktimeTooHigh
            }
            return nil
        }
        
        var valid: Bool {
            error == nil
        }
        
        init() {
        }
        
        init(task: THTask) {
            self.title = task.title ?? ""
            self.notes = task.notes ?? ""
            self.priority = task.priority
            self.earliestStartDate = task.earliestStartDate
            self.deadline = task.deadline
            self.estimatedWorktime = task.estimatedWorktime
            self.project = task.project
            self.tags = task.tags as? Set<THTag> ?? .init()
        }
    }
    
    enum Mode {
        case add
        case edit(THTask)
    }
}

struct TaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditView(mode: .add)
    }
}
