//
//  TaskRowView.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

fileprivate var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

fileprivate extension VerticalAlignment {
    struct TaskRowAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[.top]
        }
    }
    
    static let taskRowAlignment = VerticalAlignment(TaskRowAlignment.self)
}


struct TaskRowView: View {
    let task: THTask
    
    @ViewBuilder
    var circle: some View {
        if let project = task.project {
            Circle().foregroundColor(project.color.color)
        } else {
            Circle().stroke()
        }
    }
    
    var body: some View {
        HStack(alignment: .taskRowAlignment) {
            // Project Color
            circle
                .frame(width: 14)
                .alignmentGuide(.taskRowAlignment) { d in
                    d[VerticalAlignment.center]
                }
            
            // Task Title & Project Name
            VStack(alignment: .leading) {
                Text(task.title ?? "")
                    .alignmentGuide(.taskRowAlignment) { d in
                        d[VerticalAlignment.center]
                    }
                
                
                if let project = task.project {
                    
                    Text(project.name ?? "")
                        .font(.caption)
                        .foregroundColor(.secondaryLabel)
                    
                }
                
            }
            
            Spacer()
            
            // Dates
            VStack(alignment: .trailing) {
                if let deadline = task.deadline {
                    Text("\(dateFormatter.string(from: deadline))")
                        .font(.caption)
                        .alignmentGuide(.taskRowAlignment) { d in
                            d[VerticalAlignment.center]
                        }
                }
            }
        }
        .padding(.vertical, 1)
    }
}

struct TaskRowView_Previews: PreviewProvider {
    
    private struct TaskRowViewPreview: View {
        @FetchRequest(fetchRequest: THTask.all) var results: FetchedResults<THTask>
        var body: some View {
            List(results) { task in
                TaskRowView(task: task)
            }
        }
    }
    
    static var previews: some View {
        TaskRowViewPreview().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
