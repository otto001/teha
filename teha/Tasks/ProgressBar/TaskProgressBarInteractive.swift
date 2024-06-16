//
//  TaskProgressBarInteractive.swift
//  teha
//
//  Created by Matteo Ludwig on 18.01.23.
//

import Foundation
import SwiftUI




/// The teha-signature progress bar allowing the user to track and change the progress of a task.
/// This is theinteractive version for the task detail view.
struct TaskProgressBarInteractive: View {
    /// The tasks which progress to show and modify
    @ObservedObject var task: THTask
    
    /// The color of active elements (i.e., the color with which the progress bar will be filled)
    let activeColor: Color
    /// The color of inactive portion of the bar (i.e., the background color of the progress bar)
    let inactiveColor: Color
    
    /// True if the user is currently dragging
    @State private var isDragging: Bool = false
    /// The percentage of where the user has currently dragged the bar (0 = left, 1 = right, 0.5 = middle)
    @State private var draggingProgress: Double = 0
    /// Where the bar was before the user started dragging
    @State private var dragStartProgress: Double = 0
    
    /// A variable used to store where the bar was on the previous drag gesture update
    /// Used to know when to trigger haptic feedback.
    @State private var lastDraggingProgress: Double = -1
    

    init(task: THTask, activeColor: Color = .accentColor, inactiveColor: Color = .secondaryLabel) {
        self.task = task
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }
    
    /// Returns the given progress snapped to a 5 minute interval of the tasks estimatedWorktime.
    /// If the task has no estimatedWorktime, returns progress unchanged,
    private func getSnappedProgress(progress: Double) -> Double {
        guard let estimatedWorktime = task.estimatedWorktime, estimatedWorktime != .zero else {
            return progress
        }
        let totalMinutes = Double(estimatedWorktime.totalMinutes)
        
        // get total remaing minutes for progress as a double
        let totalReaminingMinutes = totalMinutes * (1 - progress)
        
        // ... round the minutes to 5 minute intervals (adding 0.01 for rounding error issues)
        let snappedRemainingMinutes = Double(5 * Int(round(totalReaminingMinutes/5))) + 0.01
        
        // turn it back into a percentage
        return 1 - (snappedRemainingMinutes / totalMinutes)
    }
    
    /// The progress given to the main slider (middle part)
    private var shownProgress: Double {
        if isDragging {
            // If is dragging, show draggingProgress as it is not snapped to 5 minutes, making the bar appear smooth
            return draggingProgress
        } else if task.isCompleted {
            // If task complete, return 100%
            return 1
        }
        return task.completionProgress
    }
    
    /// Snapped version of shownProgress
    private var snappedProgress: Double {
        return self.getSnappedProgress(progress: shownProgress)
    }
    
    /// True if the left (started) circle should be shown as active
    private var startedCircleActive: Bool {
        task.isStarted  || (isDragging && draggingProgress > 0)
    }
    
    /// True if the right (completed) circle should be shown as active
    private var completedCircleActive: Bool {
        task.isCompleted || (isDragging && draggingProgress >= 1)
    }
    
    /// Helper function to set the task to started, playing success haptic feedback.
    private func startTask() {
        task.started()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// Helper function to set the task to completed, playing success haptic feedback.
    private func completeTask() {
        task.completed()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    /// The drag gesture handling the users drag input
    private func dragGesture(gestureWidth: CGFloat, barWidth: CGFloat) -> some Gesture {
        let gesture = DragGesture(minimumDistance: 0)
            .onChanged { action in
                if !isDragging {
                    // The drag gesture has just begun, init values
                    isDragging = true
                    
                    dragStartProgress = task.completionProgress
                    draggingProgress = task.completionProgress
                    
                    // set to impossible value as the was no previous gesture update
                    lastDraggingProgress = -1
                }
                
                if abs(action.translation.width) > 1 {
                    // The user must move at least 1px
                    
                    // Update lastDraggingProgress
                    lastDraggingProgress = draggingProgress
                    
                    // Update draggingProgress, keeping in mind the actual width of the bar
                    let barPadding = gestureWidth - barWidth
                    draggingProgress = max(0, min(1, (action.location.x - barPadding/2)  / barWidth))
                    
                    // Setting the tasks completion progress to the snapped version of the progress
                    task.completionProgress = snappedProgress
                    
                    if draggingProgress != lastDraggingProgress {
                        // If the position of the bar changed, we may need to play some haptic feedback
                        
                        if task.estimatedWorktime != .zero && self.snappedProgress != self.getSnappedProgress(progress: lastDraggingProgress) {
                            // If the task has an estimated worktime and the snapped progress changed, play feedback as the user has chnaged the remaining worktime by 5 minutes.
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                        
                        if (draggingProgress == 1 && lastDraggingProgress != 1)
                        || (lastDraggingProgress == 0 && draggingProgress != 0) {
                            // If user arrives at one of the ends of the bar, play slighly more intense feedback
                            UIImpactFeedbackGenerator().impactOccurred(intensity: 0.7)
                        }
                    }
                }
            }
            .onEnded { _ in
                // Update task with final progress value
                task.completionProgress = snappedProgress
                
                // If dragging finished and we reached one of the bars ends, update tasks progress accordingly
                if draggingProgress >= 1 {
                    completeTask()
                } else if draggingProgress > 0 && !task.isStarted {
                    startTask()
                }
                
                // reset isDragging
                isDragging = false
            }
        return gesture
    }
    
    var body: some View {
        VStack {
            // Geo reader for sizing the bar
            GeometryReader { geo in
                
                HStack(spacing: 0) {
                    // Left circle (started)
                    ProgressCircleInteractive(resetConfirmationTitleKey: "mark-as-not-started-are-you-sure",
                                              resetConfirmationActionKey: "mark-as-not-started",
                                              active: startedCircleActive,
                                              activeColor: activeColor,
                                              inactiveColor: inactiveColor) {
                        // set task as started on tap
                        startTask()
                    } resetAction: {
                        // reset starting task on undo
                        task.resetStarted()
                    }
                    .zIndex(2) // place above bar in order to be tap-able
                    
                    // The main slider
                    TaskProgressBar.ProgressSlider(progress: shownProgress,
                                                   size: geo.size,
                                                   activeColor: activeColor,
                                                   inactiveColor: inactiveColor)
                    .zIndex(1) // place bar behind circles to not make them un-tap-able
                    
                    // Right circle()
                    ProgressCircleInteractive(resetConfirmationTitleKey: "mark-as-not-completed-are-you-sure",
                                              resetConfirmationActionKey: "mark-as-not-completed",
                                              active: completedCircleActive,
                                              activeColor: activeColor,
                                              inactiveColor: inactiveColor) {
                        // set task as completed on tap
                        completeTask()
                    } resetAction: {
                        // reset completing task on undo
                        task.resetCompleted()
                    }
                    .zIndex(2) // place above bar in order to be tap-able
                    
                }
                // adding the drag gesture
                .gesture(dragGesture(gestureWidth: geo.size.width, barWidth: geo.size.width - geo.size.height*2))
            }
            .frame(height: 16)
            
            // If there is estimatedWorktime remaining, show that underneath the progressbar
            if let estimatedWorktime = task.estimatedWorktime, estimatedWorktime > .zero,
                !task.isCompleted,
               let timeRemaining = estimatedWorktime.percentage(1 - snappedProgress).formatted {
                Text("\(timeRemaining)-worktime-remaining")
                    .monospacedDigit()
                    .foregroundColor(.secondaryLabel)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                // For spacing reasons, always have a text below. Using a text instead of a spacer makes the spacing automatically grow and shrink with dynamic font sizes
                Text(" ").font(.caption)
            }
        }
    }
}

extension TaskProgressBarInteractive {
    
    /// The interactive circles used left and right of the main slider.
    /// Allow the user to tap to do, and tap again to reset (with a build-in confirmation dialog)
    struct ProgressCircleInteractive: View {
        /// The title of the confirmation dialog for resetting
        let resetConfirmationTitleKey: LocalizedStringKey
        /// The title of the confirmation dialog ok button for resetting
        let resetConfirmationActionKey: LocalizedStringKey
        
        /// True if circle filled, false otherwise
        let active: Bool
        
        let activeColor: Color
        let inactiveColor: Color
        
        /// The closure to call on the when not active
        let action: () -> Void
        /// The closure to call on the when already active
        let resetAction: () -> Void
        
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
                    resetAction()
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
