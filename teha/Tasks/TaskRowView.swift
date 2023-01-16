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
    @ObservedObject var task: THTask
    
    @EnvironmentObject var router: Router
    
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
                ZStack(alignment: .topLeading) {
                    // In order to support automatic line breaks in tasks while preserving the layout, we use a Text with a single line that is overlayed with the text but invisible
                    // Yes its as dumb as it sounds but the only (simple) solution i could come up with
                    Text("X")
                        .foregroundColor(.clear)
                        .alignmentGuide(.taskRowAlignment) { d in
                            d[VerticalAlignment.center]
                        }
                    Text(task.title ?? "")
                        .lineLimit(2)
                    
                }
                
                
                if let project = task.project {
                    
                    Text(project.name ?? "")
                        .lineLimit(1)
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
                        .foregroundColor(deadline < .now ? .red : .label)
                        .alignmentGuide(.taskRowAlignment) { d in
                            d[VerticalAlignment.center]
                        }
                }
            }
        }
        .padding(.vertical, 1)
        .contentShape(Rectangle())
        .onTapGesture {
            router.push(task)
        }
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
