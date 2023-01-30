//
//  TaskOrderSuggestionsViewModel.swift
//  teha
//
//  Created by Matteo Ludwig on 28.01.23.
//

import Foundation

@MainActor
class SuggestionsViewModel: ObservableObject {
    
    /// The singleton instance of SuggestionsViewModel. Automatically reacts to viewContexts saves.
    static let shared: SuggestionsViewModel = .init()
    
    /// Whether the viewModel is currently working on a new set of results.
    @Published private(set) var isRefreshing: Bool = false
    
    /// The latest avaliable result of the SuggestionsGenerator. Call refresh to update. If the latest refresh failed, this value will be nil.
    @Published private(set) var latestResult: SuggestionsGenerator.Result?
    
    /// The error thrown on the last refresh operation. If the latest refresh operation completed successfully, this value will be nil.
    @Published private(set) var latestError: SuggestionsGeneratorError?
    
    private var isStarted: Bool = true
    
    /// The last started perform refresh task
    private var currentPerformRefreshTask: Task<Void, Never>?
    
    private init() {
    }
    
    /// Starts the event listeners of this viewModel (see listenForSaveNotification)
    func start() {
        guard !self.isStarted else { return }
        
        Task {
            await self.listenForSaveNotification()
        }
        self.isStarted = true
    }
    
    /// Listens for save events of the view context and starts a refresh operation for every save, allowing this viewModel to stay up-to-date automatically
    private func listenForSaveNotification() async {
        for await _ in NotificationCenter.default.notifications(named: Notification.Name.NSManagedObjectContextDidSave) {
            Task {
                await self.refresh()
            }
        }
    }
    
    /// Re-calculates the order and latestStartDate of tasks, updating the viewModel once the update is completed.
    @MainActor func refresh() async {
        
        // If a refresh task is already running, cancel it and wait for it to complete before starting a new task
        if let currentPerformRefreshTask = self.currentPerformRefreshTask {
            currentPerformRefreshTask.cancel()
            await currentPerformRefreshTask.value
        }
        
        guard !self.isRefreshing else {
            // This check prevents us from starting multiple concurrent refresh tasks, which would be useless
            // If we end up in this closure, another task raced us and won, so we just exit
            // This is completetly race-condition safe, since this function is executed on the MainActor, which is serial
            return
        }
        
        // Setting isRefreshing to true not only allows views to display a loading indicator, but also is an essential part of ensuring that only one refresh tasks runs at a time
        self.isRefreshing = true
        
        // Starting the actual refetch task
        self.currentPerformRefreshTask = Task(priority: .high) {
            await self.performRefresh()
            
            // If refresh is complete, set isRefreshing to false to update views loading indicators and allow for a new refresh task to start
            self.isRefreshing = false
        }
        
        // Wait until refresh task completes
        await self.currentPerformRefreshTask!.value
    }
    
    
    /// Performs the actual refresh. Creates a SuggestionsGenerator and lets it run, updating the viewModel on success or failure. Can be cancelled.
    private func performRefresh() async {
        do {
            let generator = SuggestionsGenerator(now: .now)
            
            // Sucess
            self.latestResult = try await generator.calculate()
            self.latestError = nil
            
        } catch let error as SuggestionsGeneratorError {
            self.latestError = error
            self.latestResult = nil
            
        } catch is CancellationError {
            // If task was cancelled, there is nothing to update
            return
            
        } catch {
            // This should not happend, but just to be safe we added an internal error case
            self.latestError = .internalError
            self.latestResult = nil
        }
    }
}

