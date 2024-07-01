//
//  TaskProgressBar.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import SwiftUI


/// The teha-signature progress bar allowing the user to track the progress of a task.
/// This is the non-interactive version for displaying tasks in a list etc...
struct TaskProgressBar: View {
    /// The tasks which progress to show
    @ObservedObject var task: THTask
    
    /// The color of active elements (i.e., the color with which the progress bar will be filled)
    let activeColor: Color
    /// The color of inactive portion of the bar (i.e., the background color of the progress bar)
    let inactiveColor: Color
    
    init(task: THTask, activeColor: Color = .accentColor, inactiveColor: Color = .secondaryLabel) {
        self.task = task
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }
    
    var shownProgress: Double {
        if !task.isStarted {
            // if the task is not started, its progression must be shown as 0%
            return 0
        } else if task.isCompleted {
            // if the task is not started, its progression must be shown as 100%
            return 1
        }
        // If task is started bu not completed, get progress from database value
        return task.completionProgress
    }
    
    
    var body: some View {
        GeometryReader { geo in
            // geo needed for the ProgressSlider
            
            HStack(spacing: 0) {
                ProgressCircle(active: task.isStarted,
                               activeColor: activeColor,
                               inactiveColor: inactiveColor)
                
                ProgressSlider(progress: shownProgress,
                               size: geo.size,
                               activeColor: activeColor,
                               inactiveColor: inactiveColor)
                
                ProgressCircle(active: task.isCompleted,
                               activeColor: activeColor,
                               inactiveColor: inactiveColor)
            }
        }
        .frame(maxHeight: 16)
    }
}

extension TaskProgressBar {
    /// A helper view for the circles left and right of the main slider.
    struct ProgressCircle: View {
        let active: Bool
        
        let activeColor: Color
        let inactiveColor: Color
        
        var body: some View {
            Circle()
                .fill(active ? activeColor : inactiveColor)
        }
    }
    
    /// A helper view that constructs the main slider.
    struct ProgressSlider: View {
        let progress: Double
        
        /// The size read by the GeometryReader of the parent
        let size: CGSize
        
        let activeColor: Color
        let inactiveColor: Color
        
        /// The width of the slider. Smaller that the avaliable width to account for the circles left and right.
        private var barWidth: CGFloat {
            size.width - size.height
        }
        
        /// The height of the slider
        private var height: CGFloat {
            size.height
        }
        
        /// The scale with wich to scale the circlular cut-outs at the ends of the slider
        let circleScaleFactor: CGFloat = 1.5
        
        /// The inset in pixels where the visible part of the bar starts
        /// This is needed to correctly fill the bar depending on the tasks progression
        /// It calculates how far the edge of the visible part of the view is away from the views edges.
        /// If circleScaleFactor == 1, this inset is zero. It grows with the circleScaleFactor.
        var inset: CGFloat {
            // Math credit (https://mathworld.wolfram.com/Circle-LineIntersection.html)
            // Could this be done simpler? Probably. Do I care? Not so much.
            let circleRadius = height/2 * circleScaleFactor
            let p1 = CGPoint(x: -1, y: height/2)
            let p2 = CGPoint(x: 1, y: height/2)
            let dX = (p2.x - p1.x)
            let dY = (p2.y - p1.y)
            let dR = sqrt(dX*dX + dY*dY)
            let D = (p1.x*p2.y - p1.y*p2.x)
            
            let x = (D * dY + 1 * dX * sqrt(circleRadius*circleRadius * dR*dR - D*D))/(dR*dR)
            return x
        }
        
        var body: some View {
            ZStack(alignment: .leading) {
                // The background of the slider
                Rectangle()
                    .foregroundColor(inactiveColor)
                
                // The foreground, scaled to the progress that should be shown
                // In order to have the bar not be offset, we need to consider the insets caused by the circular cutouts of the slider
                Rectangle()
                    .foregroundColor(activeColor)
                    .frame(width: inset + progress * (barWidth - inset*2))
                
                // The cutouts, which give the bar its concave ends.
                // The circles have their blendMode set to destinationOut, so that they cut parts from the ends of the rectangles above.
                HStack {
                    Circle()
                        .blendMode(.destinationOut)
                        .scaleEffect(circleScaleFactor)
                    Spacer()
                    Circle()
                        .blendMode(.destinationOut)
                        .scaleEffect(circleScaleFactor)
                }
                .padding(.horizontal, -height/2)
            }
            .compositingGroup()
            .padding(.horizontal, -height/2)
        }
    }
}

// MARK: Preview

struct TaskProgressBar_Previews: PreviewProvider {
    
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
                TaskProgressBar(task: task)
            }
            
            ForEach(tasks) { task in
                TaskProgressBar(task: task)
                    .frame(width: 80, height: 5)
            }
        }
        .overlay {
            Rectangle().frame(width: 1)
        }
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
    }
}
