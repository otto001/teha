//
//  SuggestionsListView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI


fileprivate var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.formattingContext = .middleOfSentence
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

fileprivate struct SuggestionsListRow: View {
    let taskWithLatestStartDate: SuggestionsGenerator.TaskWithLatestStartDate
    
    let now: Date
    
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
            TaskRowView(task: taskWithLatestStartDate.task, now: now)
        } header: {
            HStack(spacing: 0) {
                Text("start-before-\(formattedTime)")
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


struct SuggestionsInfoBoxButton: View {
    @State private var shown: Bool = false
    
    var body: some View {
        Button {
            shown = true
        } label: {
            Image(systemName: "info.circle")
        }
        .popover(isPresented: $shown) {
            VStack(spacing: 14) {
                HStack {
                    Text("suggestions")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        shown = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundColor(.systemGray)
                            .frame(width: 26, height: 26)
                    }
                }
                Text("suggestion-infobox-text")
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
            .presentationDetents([.medium])
        }
        
    }
}

@MainActor
struct SuggestionsListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel = SuggestionsViewModel.shared
    
    @State private var now: Date = .now
    
    var isRefreshing: Bool {
        viewModel.isRefreshing
    }
    
    var tasks: [SuggestionsGenerator.TaskWithLatestStartDate] {
        viewModel.latestResult?.tasks ?? []
    }
    
    var showInfeasible: Bool {
        !(viewModel.latestResult?.isFeasible ?? true)
    }
    
    var error: SuggestionsGeneratorError? {
        viewModel.latestError
    }
    
    var showLargeProgressView: Bool {
        isRefreshing && tasks.isEmpty && error == nil
    }
    
    func refresh() {
        Task {
            await viewModel.refresh()
        }
    }
    
    @ViewBuilder var infeasibleHeader: some View {
        if showInfeasible {
            Text("suggestions-time-issues")
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundColor(.secondaryLabel)
                .font(.callout)
        }
    }
    
    @ViewBuilder var content: some View {
        if showLargeProgressView {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.secondaryLabel)
                Text("suggestions-loading")
            }
        } else if let error = error {
            VStack {
                Image(systemName: "lightbulb.slash")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                Text(error.errorDescription ?? "")
                    .padding(.bottom, 4)
                Text(error.recoverySuggestion ?? "")
                    .font(.caption)
                    .foregroundColor(.secondaryLabel)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
        } else {
            List {
                infeasibleHeader
                
                ForEach(tasks) { taskWithLatestStartDate in
                    SuggestionsListRow(taskWithLatestStartDate: taskWithLatestStartDate, now: now)
                }
            }
        }
    }
    
    var body: some View {
        content
            .autoRefresh(now: $now)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    HStack {
                        if isRefreshing && !showLargeProgressView {
                            ProgressView()
                                .tint(.secondaryLabel)
                        }
                        SuggestionsInfoBoxButton()
                    }
                }
            }
        .onAppear {
            refresh()
        }
    }
}

struct SuggestionsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SuggestionsListView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .navigationTitle(LocalizedStringKey("suggestions"))
        }
    }
}
