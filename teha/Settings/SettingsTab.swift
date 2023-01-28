//
//  SettingsView.swift
//  teha
//
//  Created by Second Dude on 10.01.23.
//

import SwiftUI

enum SettingsAppStorageKey: String {
    case accentColor = "settings.accentColor"
    case onboardingDone = "settings.onboardingDone"
}

struct AdvancedSettings: View {
    @AppStorage(SettingsAppStorageKey.onboardingDone.rawValue) private var onboardingDone: Bool = false
    
    var body: some View {
        Form {
            Button {
                onboardingDone = false
            } label: {
                Text("onboarding-show")
            }
        }
    }
}

struct SettingsTab: View {
    @AppStorage(SettingsAppStorageKey.accentColor.rawValue) private var accentColor: ColorChoice = .blue
    
    var body: some View {
        NavigationStack {
            Form {
                SimpleColorPicker(title: "color-accent", selection: $accentColor)

                Section {
                    NavigationLink("advanced-settings") {
                        AdvancedSettings()
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings"))
        }
        .tabItem {
            Label(LocalizedStringKey("settings"), systemImage: "gear")
        }
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
    }
}
