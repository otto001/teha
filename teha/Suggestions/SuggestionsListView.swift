//
//  SuggestionsListView.swift
//  teha
//
//  Created by Matteo Ludwig on 27.01.23.
//

import SwiftUI

/**
    Creates and returns a DateFormatter instance configured for medium date and short time style, formatting context of middle of sentence, and relative date formatting.

    The formatter is used to format date and time values in a readable format.

    - Returns: A DateFormatter instance with the specified configurations.
 */
fileprivate var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.formattingContext = .middleOfSentence
    formatter.doesRelativeDateFormatting = true
    return formatter
}()

/**
 A view that displays a single row of task information in the SuggestionsList.
 
 The view is composed of a Section that contains a `TaskRowView` and a header with start time information.
 It also optionally includes a footer with remaining worktime if available. If the computed start time has passed, the the messages will be colored red.
 
 - Returns: A view displaying a single row of task information including the start time in order to be on time.
 */

fileprivate struct SuggestionsListRow: View {
    /// Wrapper around task that also contains the latest start date
    let taskWithLatestStartDate: SuggestionsGenerator.TaskWithLatestStartDate
    
    let now: Date
    
    /// Computed boolean indicating if the latest start date has passed the current date.
    var hasMissedStart: Bool {
        taskWithLatestStartDate.latestStartDate < .now
    }
    
    /// Computed string representation of the latest start date in a readable format.
    var formattedTime: String {
        formatter.string(for: taskWithLatestStartDate.latestStartDate) ?? ""
    }
    
    /// Computed optional string key for localized display of the remaining worktime.
    var footerText: LocalizedStringKey? {
        guard let remainingWorktime = taskWithLatestStartDate.task.estimatedWorktimeRemaining.formatted else {
            return nil
        }
        return "\(remainingWorktime)-worktime-remaining"
    }
    
    var body: some View {
        Section {
            TaskListRowView(task: taskWithLatestStartDate.task, now: now)
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

/**
    A struct that implements the `View` protocol to create a button that displays information about the suggestion tab.

    The button displays an info icon and when pressed, it toggles a popover view. The popover
    contains a title of "suggestions", a close button, and text that explains what the suggestion tab is all about.
 */
struct SuggestionsInfoBoxButton: View {
    
    /// Boolean state variable which is used to keep track of whether the popover is shown or not.
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

/**
    A struct that implements the `View` protocol and displays the list of task suggestions.

    It uses a managed object context from the environment to access data and an ObservedObject to bind to the view model.
    It displays a list of task information in sections with headers and footers, and includes a button to toggle an info popover.
    The view updates the now state variable to be the current date and time.
    It also has a computed property indicating if the view model is currently in the process of refreshing data.
    The tasks property returns an array of task information with the latest start date.

    - Returns: A list view displaying task suggestion information, with sections and headers and footers, as well as an info popover.
*/
@MainActor
struct SuggestionsListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Singelton instance of the `SuggestionsViewModel`
    @ObservedObject var viewModel = SuggestionsViewModel.shared
    
    @State private var now: Date = .now
    
    /// Computed property indicating whether the view model is currently in the process of refreshing data or not.
    var isRefreshing: Bool {
        viewModel.isRefreshing
    }
    
    /// Computed property returning an array of task information with the latest start date. If nil, an empty array is returned.
    var tasks: [SuggestionsGenerator.TaskWithLatestStartDate] {
        viewModel.latestResult?.tasks ?? []
    }
    
    /// Computed property returning a Boolean value indicating if the view model's latest result is not feasible.
    var showInfeasible: Bool {
        !(viewModel.latestResult?.isFeasible ?? true)
    }
    
    /// Computed property returning the latest error from the view model.
    var error: SuggestionsGeneratorError? {
        viewModel.latestError
    }
    
    /// Computed property returning a Boolean value indicating whether to show the enlarged progress view.
    var showLargeProgressView: Bool {
        isRefreshing && tasks.isEmpty && error == nil
    }
    
    /// Function which refreshes the data in the view model.
    func refresh() {
        Task {
            await viewModel.refresh()
        }
    }
    
    /// View builder displaying a text indicating time issues if the `showInfeasible` property is `true`.
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
    
    /// View builder displaying the main content of the view, which can be either a list of tasks suggestions, a large progress view or an error message depending on the value of `showLargeProgressView` and if `error` is not `nil`.
    @ViewBuilder var content: some View {
        if showLargeProgressView { // Show enlarged ProgressView
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.secondaryLabel)
                Text("suggestions-loading")
            }
        } else if let error = error { // Show error message
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
        } else { // Show list of tasks suggestions
            List {
                infeasibleHeader
                
                ForEach(tasks) { taskWithLatestStartDate in
                    SuggestionsListRow(taskWithLatestStartDate: taskWithLatestStartDate, now: now)
                }
            }
        }
    }
    
    /// `content` view builder is used to display the main content. The view also has a toolbar with an info button on the top right side. When the view appears, the `refresh` function is called causing the data in the view model to be refreshed.
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
