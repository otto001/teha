//
//  ContentView.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import SwiftUI
import CoreData

/// An enum of all tabs avaliable in teha.
enum Tab: String, RawRepresentable {
    case suggestions = "suggestions"
    case tasks = "tasks"
    case timeLogEntry = "timeLogEntry"
    case projects = "projects"
    case settings = "settings"
}

/// The root View of teha.
struct ContentView: View {
    @AppStorage(SettingsAppStorageKey.accentColor.rawValue) private var accentColor: ColorChoice = .blue
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    // ensure that the tasks tab is the default tab (i.e., landing page)
    @State private var tab: Tab = .tasks
    
    @AppStorage(SettingsAppStorageKey.onboardingDone.rawValue) private var onboardingDone: Bool = false
    
    var body: some View {
        Group {
            // Create root TabView and add all main views for app
            if (onboardingDone) {
                TabView(selection: $tab) {
                    SuggestionsTab().tag(Tab.suggestions)
                    TimeLogTab().tag(Tab.timeLogEntry)
                    TasksTab().tag(Tab.tasks)
                    ProjectsTab().tag(Tab.projects)
                    SettingsTab().tag(Tab.settings)
                }
                .tint(accentColor.color) // apply accent color setting to app
            } else {
                OnboardingView() // onboarding view for first-timers
            }
        }
        .animation(.easeInOut, value: onboardingDone) // animation for hiding onboarding view
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .inactive, .background:
                try? viewContext.save()
            default:
                break
            }
        }
        .onAppear {
            // By calling this as soon as the app appears, we ensure that the UserDefaults have been set up correctly.
            // The method ensures it only actually does something on first start-up
            SettingsAppStorageKey.setDefaultValuesIfNeeded()
            
            // Starting the SuggestionsViewModel in order for teha to start generating suggestions
            SuggestionsViewModel.shared.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
