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
        task.startDate = .now
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func completeTask() {
        task.completionDate = .now
        task.completionProgress = 1
        
        if task.startDate == nil {
            task.startDate = task.completionDate
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func dragGesture(barWidth: CGFloat) -> some Gesture {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { action in
                if !isDragging {
                    isDragging = true
                    
                    dragStartProgress = task.completionProgress
                    draggingProgress = task.completionProgress
                }
                
                if abs(action.translation.width) > 1 {
                    lastDraggingProgress = draggingProgress
                    
                    draggingProgress = max(0, min(1, action.translation.width / barWidth + dragStartProgress))
                    
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
                } else if draggingProgress >= 0 && !task.isStarted {
                    startTask()
                }
                
                isDragging = false
            }
        return gesture
    }
    
    // TODO: Haptic Feedback
    var body: some View {
        GeometryReader { geo in
            let spacing = geo.size.height/3
            let circleDiameter = geo.size.height
            let barWidth = geo.size.width - (circleDiameter + spacing)*2
            
            HStack(spacing: spacing) {

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
                //.disabled(isDragging)
                
                TaskProgressBar.ProgressCapsule(progress: shownProgress,
                                barWidth: barWidth,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor)
                .gesture(dragGesture(barWidth: barWidth))
                //.disabled(task.isCompleted)
                
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
                //.disabled(isDragging)

            }
        }
        .frame(maxHeight: 16)
    }
}
