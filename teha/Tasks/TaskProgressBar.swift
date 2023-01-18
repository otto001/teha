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
            let spacing = geo.size.height/3
            let circleDiameter = geo.size.height
            let barWidth = geo.size.width - (circleDiameter + spacing)*2
            
            HStack(spacing: spacing) {
                ProgressCircle(active: task.isStarted,
                               activeColor: activeColor,
                               inactiveColor: inactiveColor)
                
                ProgressCapsule(progress: progress,
                                barWidth: barWidth,
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

    struct ProgressCapsule: View {
        let progress: Double
        let barWidth: CGFloat
        
        let activeColor: Color
        let inactiveColor: Color
        
        var body: some View {
            ZStack(alignment: .leading) {
                
                Rectangle()
                    .foregroundColor(inactiveColor)
                Rectangle()
                    .foregroundColor(activeColor)
                    .frame(width: barWidth * progress)
            }
            .clipShape(Capsule())
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
        .padding(.horizontal)
    }
}
