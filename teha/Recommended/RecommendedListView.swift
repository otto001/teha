//
//  RecommendedListView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

// The formatter used in TaskRowView for the remining time until deadline
fileprivate var timeRemainingFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    formatter.dateTimeStyle = .named
    formatter.formattingContext = .middleOfSentence
    
    return formatter
}()

// The formatter used in TaskRowView for the remining time until deadline
fileprivate var formatter: DateFormatter = {
    let formatter = DateFormatter()
    //formatter.unitsStyle = .full
    //formatter.dateTimeStyle = .named
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.formattingContext = .middleOfSentence
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

fileprivate struct RecommendedListRow: View {
    let taskWithLatestStartDate: TaskOrderRecommendationGenerator.TaskWithLatestStartDate
    
    var hasMissedStart: Bool {
        taskWithLatestStartDate.latestStartDate < .now
    }
    
    var formattedTime: String {
        formatter.string(for: taskWithLatestStartDate.latestStartDate) ?? ""
    }
    
    var footerText: LocalizedStringKey? {
        guard let remainingWorktime = taskWithLatestStartDate.task.estimatedWorktimeRemaining.formatted else {
            return nil
        }
        return "\(remainingWorktime)-worktime-remaining"
    }
    
    var body: some View {
        Section {
            TaskRowView(task: taskWithLatestStartDate.task)
        } header: {
            HStack(spacing: 0) {
                Text("Start before ")
                Text(formattedTime)
                    .foregroundColor(hasMissedStart ? .red : .label)
            }
            .textCase(.none)
            .foregroundColor(.secondaryLabel)
            .fontWeight(.medium)
            
        } footer: {
            if let footerText = footerText {
                Text(footerText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.caption2)
            }
        }
    }
}


struct RecommendedListView: View {
    
    @State var tasks: [TaskOrderRecommendationGenerator.TaskWithLatestStartDate] = []
    @State var showInfeasible: Bool = false
    
    
    func refresh() {
        Task {
            let generator = TaskOrderRecommendationGenerator(start: .now)
            guard let result = await generator.calculate() else { return }
            
            await MainActor.run {
                self.tasks = result.tasks
                self.showInfeasible = !result.isFeasible
            }
        }
    }
    
    @ViewBuilder var infeasibleHeader: some View {
        if showInfeasible {
            Text("You may run into some time issues.")
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundColor(.secondaryLabel)
                .padding(.bottom, -20)
        }
    }
    
    var body: some View {
        List {
            infeasibleHeader
            
            ForEach(tasks) { taskWithLatestStartDate in
                RecommendedListRow(taskWithLatestStartDate: taskWithLatestStartDate)
            }
        }
        .onAppear {
            refresh()
        }
    }
}

struct RecommendedListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecommendedListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .navigationTitle("Suggestions")
        }
    }
}
