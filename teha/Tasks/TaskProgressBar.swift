//
//  TaskProgressBar.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import SwiftUI

fileprivate struct ProgressCapsule: View {
    let titleKey: LocalizedStringKey
    
    @Binding var date: Date?
    
    let resetConfirmationTitleKey: LocalizedStringKey
    let resetConfirmationActionKey: LocalizedStringKey
    
    let skipped: Bool
    
    @State private var confirmationDialog: Bool = false
    
    init(titleKey: LocalizedStringKey,
         date: Binding<Date?>,
         resetConfirmationTitleKey: LocalizedStringKey,
         resetConfirmationActionKey: LocalizedStringKey,
         skipped: Bool = false) {
        
        self.titleKey = titleKey
        self._date = date
        self.resetConfirmationTitleKey = resetConfirmationTitleKey
        self.resetConfirmationActionKey = resetConfirmationActionKey
        self.skipped = skipped
    }
    
    private var active: Bool {
        date != nil || skipped
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            Capsule()
                .fill(active ? .accentColor : Color.systemGray4)
                .frame(height: 16)
            Text(titleKey)
                .font(.caption2)
                .textCase(.none)
                .padding(.horizontal, 5)
                .foregroundColor(active ? .accentColor : Color.secondaryLabel)
        }
        .onTapGesture {
            guard !skipped else { return }
            if date == nil {
                date = .now
            } else {
                confirmationDialog = true
            }
        }
        .confirmationDialog(resetConfirmationTitleKey, isPresented: $confirmationDialog) {
            Button {
                date = nil
            } label: {
                Text(resetConfirmationActionKey)
            }
            
            Button("cancel", role: .cancel) {
                confirmationDialog = false
            }
        } message: {
            Text(resetConfirmationTitleKey)
        }
    }
}

struct TaskProgressBar: View {
    @ObservedObject var task: THTask
    
    var completedBinding: Binding<Date?> {
        Binding {
            return task.completionDate
        } set: { newValue, _ in
            task.completionDate = newValue
            if task.startDate == nil && newValue != nil {
                task.startDate = newValue
            }
        }

    }
    
    var body: some View {
        HStack {
            ProgressCapsule(titleKey: "started",
                            date: $task.startDate,
                            resetConfirmationTitleKey: "mark-as-not-started-are-you-sure",
                            resetConfirmationActionKey: "mark-as-not-started",
                            skipped: task.completionDate != nil)
            
            ProgressCapsule(titleKey: "completed",
                            date: completedBinding,
                            resetConfirmationTitleKey: "mark-as-not-completed-are-you-sure",
                            resetConfirmationActionKey: "mark-as-not-completed")
        }
        .frame(maxWidth: .infinity)
    }
}

struct TaskProgressBar_Previews: PreviewProvider {
    
    static var task: THTask {
        let task = try! PersistenceController.preview.container.viewContext.fetch(THTask.all).first!
        task.startDate = .now
        return task
    }
    
    static var previews: some View {
        TaskProgressBar(task: task)
    }
}
