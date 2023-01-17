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
    
    // ensure that the tasks tab is the default tab (i.e., landing page)
    @State private var tab: Tab = .tasks
    
    @AppStorage(SettingsAppStorageKey.onboardingdone.rawValue) private var onboardingdone: Bool = false
    @State private var currentTab = 0
    
    var body: some View {
        // Create root TabView and add all main views for app
        if(onboardingdone){
            TabView(selection: $tab) {
                ProjectsTab().tag(Tab.projects)
                TasksTab().tag(Tab.tasks)
                SettingsTab().tag(Tab.settings)
            }
            .tint(accentColor.color)
        }
        else {
            VStack {
                TabView(selection: $currentTab, content: {
                    ForEach(OnboardingData.list) { viewData in
                        OnboardingView(data: viewData)
                            .tag(viewData.id)
                    }
                })
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                Button(action:{
                    onboardingdone = true
                }, label: {
                    Text("get-started")
                        .font(.headline)
                        .foregroundColor(.label)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20))
                })
                .shadow(radius: 10)
            }
        }// apply accent color setting to app
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
