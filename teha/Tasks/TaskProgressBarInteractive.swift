//
//  TaskProgressBarInteractive.swift
//  teha
//
//  Created by Matteo Ludwig on 18.01.23.
//

import Foundation
import SwiftUI



fileprivate struct ProgressCircleInteractive: View {
    let titleKey: LocalizedStringKey
    
    let resetConfirmationTitleKey: LocalizedStringKey
    let resetConfirmationActionKey: LocalizedStringKey
    
    let active: Bool
    
    let activeColor: Color
    let inactiveColor: Color
    
    let action: () -> Void
    let undoAction: () -> Void
    
    @State private var confirmationDialog: Bool = false
    
    var body: some View {
        TaskProgressBar.ProgressCircle(active: active,
                                       activeColor: activeColor,
                                       inactiveColor: inactiveColor)
        .onTapGesture {
            if !active {
                action()
            } else {
                confirmationDialog = true
            }
        }
        .confirmationDialog(resetConfirmationTitleKey, isPresented: $confirmationDialog) {
            Button {
                undoAction()
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

struct TaskProgressBarInteractive: View {
    @ObservedObject var task: THTask
    
    let activeColor: Color
    let inactiveColor: Color
    
    @State private var isDragging: Bool = false
    @State private var draggingProgress: Double = 0
    @State private var dragStartProgress: Double = 0
    
    @State private var lastDraggingProgress: Double = 0
    
    var thresholds: [Double] {
        [0, 1]
    }
    
    init(task: THTask, activeColor: Color = .accentColor, inactiveColor: Color = .secondaryLabel) {
        self.task = task
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }
    
    var shownProgress: Double {
        if isDragging {
            return draggingProgress
        } else if task.isCompleted {
            return 1
        }
        return task.completionProgress
    }
    
    var startedCircleActive: Bool {
        task.isStarted  || (isDragging && draggingProgress > 0)
    }
    
    var completedCircleActive: Bool {
        task.isCompleted || (isDragging && draggingProgress >= 1)
    }
    
    private func startTask() {
        task.started()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func completeTask() {
        task.completed()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func dragGesture(gestureWidth: CGFloat, barWidth: CGFloat) -> some Gesture {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { action in
                if !isDragging {
                    isDragging = true
                    
                    dragStartProgress = task.completionProgress
                    draggingProgress = task.completionProgress
                }
                
                if abs(action.translation.width) > 1 {
                    lastDraggingProgress = draggingProgress
                    
                    let barPadding = gestureWidth - barWidth
                    draggingProgress = max(0, min(1, (action.location.x - barPadding/2)  / barWidth))
                    task.completionProgress = draggingProgress
                    if draggingProgress != lastDraggingProgress {
                        
                        for threshold in thresholds {
                            if draggingProgress >= threshold && lastDraggingProgress <= threshold {
                                UISelectionFeedbackGenerator().selectionChanged()
                                break
                            }
                        }
                    }
                }
            }
            .onEnded { _ in
                
                task.completionProgress = draggingProgress
                if draggingProgress >= 1 {
                    completeTask()
                } else if draggingProgress > 0 && !task.isStarted {
                    startTask()
                }
                
                isDragging = false
            }
        return gesture
    }
    
    var body: some View {
        GeometryReader { geo in
            
            HStack(spacing: 0) {
                
                ProgressCircleInteractive(titleKey: "started",
                                          resetConfirmationTitleKey: "mark-as-not-started-are-you-sure",
                                          resetConfirmationActionKey: "mark-as-not-started",
                                          active: startedCircleActive,
                                          activeColor: activeColor,
                                          inactiveColor: inactiveColor) {
                    startTask()
                } undoAction: {
                    task.startDate = nil
                    task.completionDate = nil
                    task.completionProgress = 0
                }
                .zIndex(2)
                
                TaskProgressBar.ProgressSlider(progress: shownProgress,
                                                size: geo.size,
                                                activeColor: activeColor,
                                                inactiveColor: inactiveColor)
                .zIndex(1)
                
                ProgressCircleInteractive(titleKey: "completed",
                                          resetConfirmationTitleKey: "mark-as-not-completed-are-you-sure",
                                          resetConfirmationActionKey: "mark-as-not-completed",
                                          active: completedCircleActive,
                                          activeColor: activeColor,
                                          inactiveColor: inactiveColor) {
                    
                    completeTask()
                } undoAction: {
                    task.completionDate = nil
                }
                .zIndex(2)
                
            }
            .gesture(dragGesture(gestureWidth: geo.size.width, barWidth: geo.size.width - geo.size.height*2))
        }
        .frame(maxHeight: 16)
    }
}


struct TaskProgressBarInteractive_Previews: PreviewProvider {
    
    static var tasks: [THTask] {
        let tasks = Array(try! PersistenceController.preview.container.viewContext.fetch(THTask.all)[..<4])
        
        tasks[0].startDate = nil
        tasks[0].completionProgress = 0
        tasks[0].completionDate = nil
        
        tasks[1].startDate = .now
        tasks[1].completionProgress = 0
        tasks[1].completionDate = nil
        
        tasks[2].startDate = .now
        tasks[2].completionProgress = 0.5
        tasks[2].completionDate = nil
        
        tasks[3].startDate = .now
        tasks[3].completionProgress = 1
        tasks[3].completionDate = .now
        return tasks
    }
    
    static var previews: some View {
        VStack(spacing: 10) {
            ForEach(tasks) { task in
                TaskProgressBarInteractive(task: task)
            }
        }
        .overlay {
            Rectangle().frame(width: 1)
        }
        .padding(.horizontal)
    }
}
