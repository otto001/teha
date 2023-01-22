//
//  TaskProgressBar.swift
//  teha
//
//  Created by Matteo Ludwig on 16.01.23.
//

import SwiftUI



struct TaskProgressBar: View {
    @ObservedObject var task: THTask

    let activeColor: Color
    let inactiveColor: Color
    
    init(task: THTask, activeColor: Color = .accentColor, inactiveColor: Color = .secondaryLabel) {
        self.task = task
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
    }
    
    var progress: Double {
        if !task.isStarted {
            return 0
        } else if task.isCompleted {
            return 1
        }
        return task.completionProgress
    }
    
    
    var body: some View {
        GeometryReader { geo in

            HStack(spacing: 0) {
                ProgressCircle(active: task.isStarted,
                               activeColor: activeColor,
                               inactiveColor: inactiveColor)
                
                ProgressSlider(progress: progress,
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
    struct ProgressCircle: View {
        let active: Bool
        
        let activeColor: Color
        let inactiveColor: Color
        
        var body: some View {
            Circle()
                .fill(active ? activeColor : inactiveColor)
        }
    }

    struct ProgressSlider: View {
        let progress: Double
        let size: CGSize
        
        let activeColor: Color
        let inactiveColor: Color
        
        private var barWidth: CGFloat {
            size.width - size.height
        }
        
        private var height: CGFloat {
            size.height
        }

        private var circleScaleFactor: CGFloat {
            return 1.5
        }
        
        /// The inset in pixels where the visible part of the bar starts
        var inset: CGFloat {
            // Math (https://mathworld.wolfram.com/Circle-LineIntersection.html)
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
                
                Rectangle()
                    .foregroundColor(inactiveColor)
                Rectangle()
                    .foregroundColor(activeColor)
                    .frame(width: inset + progress * (barWidth - inset*2))
                
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
