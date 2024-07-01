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
    @AppStorage(SettingsAppStorageKey.endOfWorkDay.rawValue) var endOfWorkDay: Worktime = .init(hours: 8, minutes: 0)

   
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
        } set: { (newValue: THProject?) in
            data.project = newValue
            data.priority = newValue?.priority ?? data.priority
            data.deadlineDate = newValue?.deadlineDate ?? data.deadlineDate
        }

    }
    
    func done(updateFutureChildren: Bool? = nil) {
        guard data.valid else {
            showError = true
            return
        }
        
        guard !(task?.hasFutureRepeats() == true && updateFutureChildren == nil) else {
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
        data.apply(to: task, updateFutureRepeats: updateFutureChildren == true)
        
        if task.creationDate == nil {
            task.creationDate = Date.now
        }
        
        try? viewContext.save()
        
        NotificationManager.instance.scheduleReminderNotifications(task: task)
//        task.repeatingSiblings?.forEach { repeatingSibling in
//            NotificationManager.instance.scheduleReminderNotifications(task: repeatingSibling)
//        }

            
        GeoMonitor.shared.refreshLocationMonitoring(task: task)
       
        dismiss()
    }
    
    var defaultDeadline: Date {
        if let deadline = data.project?.deadlineDate {
            return deadline
        }
        
        var date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        date = Calendar.current.date(bySettingHour: endOfWorkDay.hours, minute: endOfWorkDay.minutes, second: 0, of: date) ?? .now
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
                                       selection: $data.deadlineDate,
                                       defaultDate: defaultDeadline)
                } footer: {
                    if data.deadlineBeforeEarliestStartDate {
                        Text(FormError.deadlineBeforeEarliestStartDate.failureReason!)
                            .foregroundColor(.red)
                    }
                }
                
                if data.deadlineDate != nil
                    && data.project?.deadlineDate != nil
                    && data.deadlineDate != data.project?.deadlineDate {
                    Section {
                        Button("task-use-project-deadline") {
                            data.deadlineDate = data.project?.deadlineDate
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

                //Section which allows the user to set a reminder and possible a second reminder. A value can only be selected if a deadline is set for the task.
                if data.deadlineDate != nil {
                    Section {
                        RepeatIntervalInput("repeat", interval: $data.repeatInterval, endDate: $data.repeatEndDate)
                    } footer: {
                        if let repeatError = data.repeatError {
                            Text(repeatError.failureReason!).foregroundColor(.red)
                        }
                    }
                    
                    Section {
                            ReminderPicker(title: "reminder", selection: $data.reminder)
                            if data.reminder != nil {
                                ReminderPicker(title: "reminder-second", selection: $data.reminderSecond)
                            }
                    }
                }
                
                Section{
                    LocationPicker("location",
                                   addText: "location-add", address: $data.address, lat: $data.lat, long: $data.long)
                }
                
                Section {
                    TextFieldMultiline(String(localized:"notes"), text: $data.notes)
                        .frame(minHeight: 72)
                }
                
            
                Section {
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
        case repeatingEndDateBeforeDeadline
        case repeatingEndDateTooFarInFuture
        
        var errorDescription: String? {
            String(localized: "cannot-save-task")
        }
        
        var failureReason: String? {
            switch self {
            case .noTitle: return String(localized: "task-must-have-title")
            case .deadlineBeforeEarliestStartDate: return String(localized: "task-deadline-must-be-after-earliest-startdate")
            case .estimatedWorktimeTooHigh: return String(localized: "estimated-worktime-too-high")
            case .repeatingEndDateBeforeDeadline: return String(localized: "repeat-deadline-after")
            case .repeatingEndDateTooFarInFuture: return String(localized: "repeat-deadline-years")
            }
        }
    }
    
    struct FormData {
        var title: String = ""
        var project: THProject?
        var priority: Priority = .normal
        
        var earliestStartDate: Date? = nil
        var deadlineDate: Date? = nil
        
        var estimatedWorktime: Worktime = .init(hours: 1, minutes: 0)
        
        var repeatInterval: RepeatInterval?
        var repeatEndDate: Date?
        var originalDeadline: Date?
        var alreadyWasRepeating: Bool = false
        
        var reminder: ReminderOffset? = nil
        var reminderSecond: ReminderOffset? = nil
        
        var address: String?
        var lat: Double?
        var long: Double?
        
        
        var notes: String = ""
        var tags: Set<THTag> = .init()
        
        /// True when the deadline is before the earliestStartDate.
        var deadlineBeforeEarliestStartDate: Bool {
            if let earliestStartDate = earliestStartDate,
               let deadline = deadlineDate,
               earliestStartDate > deadline {
                return true
            }
            return false
        }
        
        /// True when estimatedWorktime is over 48 hours.
        var estimatedWorktimeTooHigh: Bool {
            return (estimatedWorktime ?? .zero) > Worktime(hours: 48, minutes: 0)
        }
        
        var repeatError: FormError? {
            guard let repeatEndDate = repeatEndDate, let deadline = deadlineDate else {
                return nil
            }
            if repeatEndDate <= deadline {
                return .repeatingEndDateBeforeDeadline
            } else if repeatEndDate > Calendar.current.date(byAdding: .year, value: 2, to: deadline)! {
                return .repeatingEndDateTooFarInFuture
            }
            return nil
        }
        
        
        var error: FormError? {
            if title.isEmpty {
                return .noTitle
            } else if deadlineBeforeEarliestStartDate {
                return .deadlineBeforeEarliestStartDate
            } else if estimatedWorktimeTooHigh {
                return .estimatedWorktimeTooHigh
            } else if let repeatError = repeatError {
                return repeatError
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
            self.deadlineDate = task.deadlineDate
            self.estimatedWorktime = task.estimatedWorktime ?? .zero

            
//            self.address = task.address ?? ""
//            self.lat = task.lat
//            self.long = task.long

            self.repeatInterval = task.taskDescription?.repeatInterval
            self.repeatEndDate = task.taskDescription?.repeatEndDate
            self.originalDeadline = task.deadlineDate
//            self.alreadyWasRepeating = task.isRepeating
//            
//            self.reminder = task.reminderOffset
//            self.reminderSecond = task.reminderOffsetSecond
            
            self.notes = task.taskDescription?.notes ?? ""
            self.tags = task.taskDescription?.tags ?? .init()
        }
        
        func apply(to task: THTask, updateFutureRepeats: Bool) {
            let taskDescription: THTaskDescription
            
            if task.taskDescription == nil {
                taskDescription = THTaskDescription(context: task.managedObjectContext!)
            } else if task.hasPastRepeats(), let deadlineDate {
                taskDescription = THTaskDescription(context: task.managedObjectContext!)
                
                if !updateFutureRepeats {
                    task.taskDescription?.addRepeatException(date: deadlineDate)
                } else if let currentTaskDescription = task.taskDescription, let originalDeadline {
                    for task in currentTaskDescription.tasks {
                        if !task.isStarted && (task.deadlineDate ?? .distantPast) >= originalDeadline {
                            task.taskDescription = taskDescription
                        }
                    }
                    currentTaskDescription.repeatEndDate = originalDeadline.startOfDay.addingTimeInterval(-1)
                    currentTaskDescription.updateTasks()
                }
                
            } else {
                // This is safe due to the check in the if
                taskDescription = task.taskDescription!
            }
            
            task.taskDescription = taskDescription
            task.deadlineDate = deadlineDate
            
            self.apply(to: taskDescription, updateFutureRepeats: updateFutureRepeats)
        }
        
        func apply(to taskDescription: THTaskDescription, updateFutureRepeats: Bool) {
            taskDescription.title = self.title
            taskDescription.project = self.project
            taskDescription.priority = self.priority
            
            taskDescription.earliestStartDate = self.earliestStartDate
            taskDescription.deadlineDate = self.deadlineDate
            
            taskDescription.estimatedWorktime = self.estimatedWorktime
            
            taskDescription.tags = self.tags
            
            taskDescription.notes = self.notes
            
            
            
            if (updateFutureRepeats || taskDescription.tasks.count == 1) && deadlineDate != nil {
                // Do not set task to repeat if no deadline is set
                taskDescription.repeatInterval = self.repeatInterval
                taskDescription.repeatEndDate = self.repeatEndDate
            } else {
                taskDescription.repeatInterval = nil
                taskDescription.repeatEndDate = nil
            }
            
            taskDescription.updateTasks()
//
//            // Do not set reminders if no deadline is set
//            task.reminderOffset = task.deadline != nil ? self.reminder : nil
//            task.reminderOffsetSecond = task.deadline != nil ? self.reminderSecond : nil
//            
//            if let address = self.address {
//                task.address = address
//                task.lat = self.lat ?? 0
//                task.long = self.long ?? 0
//            } else {
//                task.address = ""
//                task.lat = 0
//                task.long = 0
//            }
//            
//            task.notes = self.notes
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
