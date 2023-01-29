//
//  SettingsView.swift
//  teha
//
//  Created by Andreas Romann und Matteo Ludwig on 10.01.23.
//

import SwiftUI

enum SettingsAppStorageKey: String {
    case accentColor = "settings.accentColor"
    case onboardingDone = "settings.onboardingDone"
    
    case workDays = "settings.workDays"
    case startOfWorkDay = "settings.startOfWorkDay"
    case endOfWorkDay = "settings.endOfWorkDay"
    
    case didSetDefaultValues = "settings.didSetDefaultValues"
    
    case useThemedAppIcon = "settings.useThemedAppIcon"
    
    static func setDefaultValuesIfNeeded() {
        guard UserDefaults.standard.value(forKey: didSetDefaultValues.rawValue) as? Bool != true else { return }
        UserDefaults.standard.set(Worktime(hours: 8, minutes: 0).rawValue, forKey: startOfWorkDay.rawValue)
        UserDefaults.standard.set(Worktime(hours: 16, minutes: 0).rawValue, forKey: endOfWorkDay.rawValue)
        UserDefaults.standard.set(Set<Int>([1,2,3,4,5]).rawValue, forKey: workDays.rawValue)
        UserDefaults.standard.set(true, forKey: didSetDefaultValues.rawValue)
        UserDefaults.standard.set(true, forKey: useThemedAppIcon.rawValue)
    }
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
    @AppStorage(SettingsAppStorageKey.useThemedAppIcon.rawValue) private var useThemedAppIcon: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                WorkDaysSettingsView()
                
                SimpleColorPicker(title: "color-accent", selection: $accentColor)
                Toggle("settings-use-themed-appicon", isOn: $useThemedAppIcon)
                
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
