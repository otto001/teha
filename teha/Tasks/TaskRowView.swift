//
//  TaskRowView.swift
//  teha
//
//  Created by Matteo Ludwig on 04.01.23.
//

import SwiftUI

struct TaskRowView: View {
    let task: THTask
    
    var body: some View {
        Text(task.title ?? "")
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
