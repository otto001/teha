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
    
    // Used for setting the default deadline
    @AppStorage(SettingsAppStorageKey.startOfWorkDay.rawValue) var startOfWorkDay: Worktime = .init(hours: 8, minutes: 0)
   
    @State var data = FormData()
    
    @State var showError: Bool = false
    @State var showRepeatingUpdateChoices: Bool = false
    
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
    
    func done(updateFutureChildren: Bool? = nil) {
        guard data.valid else {
            showError = true
            return
        }
        

        guard !(task?.hasFutureSiblings() == true && updateFutureChildren == nil) else {
            print("showRepeatingUpdateChoices")
            if showRepeatingUpdateChoices == true {
                showRepeatingUpdateChoices = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    showRepeatingUpdateChoices = true
                }
            } else {
                showRepeatingUpdateChoices = true
            }
            return
        }
        
        let task = task ?? THTask(context: viewContext)
        data.apply(to: task)
        
        if task.creationDate == nil {
            task.creationDate = Date.now
        }
        
        let updateFutureChildren = !data.alreadyWasRepeating || updateFutureChildren!
        task.updateRepeat(context: viewContext, oldDeadline: data.originalDeadline, updateFutureChildren: updateFutureChildren)
        
        // TODO: error handling
        try? viewContext.save()
        
        // TODO: Move NotificationManager code to somewhere else
        NotificationManager.instance.scheduleReminderNotifications(task: task)
        
        task.repeatingSiblings?.forEach { repeatingSibling in
            NotificationManager.instance.scheduleReminderNotifications(task: repeatingSibling)
        }

        dismiss()
    }
    
    var defaultDeadline: Date {
        var date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        date = Calendar.current.date(bySettingHour: startOfWorkDay.hours, minute: startOfWorkDay.minutes, second: 0, of: date) ?? .now
        return date
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
                                       selection: $data.deadline,
                                       defaultDate: defaultDeadline)
                } footer: {
                    if data.deadlineBeforeEarliestStartDate {
                        Text(FormError.deadlineBeforeEarliestStartDate.failureReason!)
                            .foregroundColor(.red)
                    }
                }
                
                if data.project != nil && data.deadline != data.project!.deadline {
                    Section {
                        Button("task-use-project-deadline") {
                            data.useProjectDeadline = true
                        }
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

                if data.deadline != nil {
                    Section {
                        RepeatIntervalInput("repeat", interval: $data.repeatInterval, endDate: $data.repeatEndDate)
                    }
                    
                    Section {
                            ReminderPicker(title: "reminder", selection: $data.reminder)
                            if data.reminder != nil {
                                ReminderPicker(title: "reminder-second", selection: $data.reminderSecond)
                            }
                    }
                }
                
                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $data.notes)
                        .frame(minHeight: 72)
                    TagPicker(selection: $data.tags)
                }
            }
            .formSheetNavigationBar(navigationTitle: navigationTitle, editing: editing, valid: data.valid) {
                done()
            } cancel: {
                dismiss()
            }
            
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
        .confirmationDialog("repeating-update-future-prompt", isPresented: $showRepeatingUpdateChoices) {
            Button("repeating-update-future") {
                self.done(updateFutureChildren: true)
            }
            Button("repeating-update-only-self") {
                self.done(updateFutureChildren: false)
            }
            
        } message: {
            Text("repeating-update-future-prompt")
        }
        .onAppear {
            if let task = task {
                self.data = .init(task: task)
            }
            
            NotificationManager.instance.requestAuthorization()
        }
        .interactiveDismissDisabled()
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
        var project: THProject?
        var priority: Priority = .normal
        
        var earliestStartDate: Date? = nil
        
        var deadlineOverride: Date? = nil
        var useProjectDeadline = true
        var deadline: Date? {
            get {
                if useProjectDeadline {
                    return project?.deadline
                } else {
                    return deadlineOverride
                }
            }
            set {
                deadlineOverride = newValue
                useProjectDeadline = deadlineOverride == project?.deadline
            }
        }
        
        var estimatedWorktime: Worktime = .init(hours: 1, minutes: 0)
        
        var repeatInterval: RepeatInterval?
        var repeatEndDate: Date?
        var originalDeadline: Date?
        var alreadyWasRepeating: Bool = false
        
        var reminder: ReminderOffset? = nil
        var reminderSecond: ReminderOffset? = nil
        
        var notes: String = ""
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
        
        /// True when estimatedWorktime is over 48 hours.
        var estimatedWorktimeTooHigh: Bool {
            return estimatedWorktime > Worktime(hours: 48, minutes: 0)
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
            self.project = task.project
            self.priority = task.priority
            
            self.earliestStartDate = task.earliestStartDate
            self.deadlineOverride = task.deadlineOverride
            self.useProjectDeadline = task.useProjectDeadline
            self.estimatedWorktime = task.estimatedWorktime
            
            self.repeatInterval = task.repeatInterval
            self.repeatEndDate = task.repeatEndDate
            self.originalDeadline = task.deadline
            self.alreadyWasRepeating = task.isRepeating
            
            self.reminder = task.reminderOffset
            self.reminderSecond = task.reminderOffsetSecond
            
            self.notes = task.notes ?? ""
            self.tags = task.tags as? Set<THTag> ?? .init()
        }
        
        func apply(to task: THTask) {
            task.title = self.title
            task.project = self.project
            task.priority = self.priority
            
            task.earliestStartDate = self.earliestStartDate
            task.deadline = self.deadline
            
            task.estimatedWorktime = self.estimatedWorktime
            
            task.repeatInterval = self.repeatInterval
            task.repeatEndDate = self.repeatEndDate
            
            task.reminderOffset = self.reminder
            task.reminderOffsetSecond = self.reminderSecond
            
            task.notes = self.notes
            task.tags = self.tags as NSSet
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
