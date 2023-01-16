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
    case projects = "projects"
    case tasks = "tasks"
    case settings = "settings"
}

/// The root View of teha.
struct ContentView: View {
    @AppStorage(SettingsAppStorageKey.accentColor.rawValue) private var accentColor: ColorChoice = .blue
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    // ensure that the tasks tab is the default tab (i.e., landing page)
    @State private var tab: Tab = .tasks
    
    var body: some View {
        // Create root TabView and add all main views for app
        TabView(selection: $tab) {
            ProjectsTab().tag(Tab.projects)
            TasksTab().tag(Tab.tasks)
            SettingsTab().tag(Tab.settings)
        }
        .tint(accentColor.color) // apply accent color setting to app
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .inactive, .background:
                try? viewContext.save()
            default:
                break
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
