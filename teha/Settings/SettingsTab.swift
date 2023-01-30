//
//  SettingsView.swift
//  teha
//
//  Created by Andreas Romann und Matteo Ludwig on 10.01.23.
//

import SwiftUI

/// enum for all UserDefaults set for the app.
enum SettingsAppStorageKey: String {
    // UserDefault for the AccentColor of the app
    case accentColor = "settings.accentColor"
    // UserDefault if the Onboarding has been done. Is also used to let the OnboardingView reappear
    case onboardingDone = "settings.onboardingDone"

    // UserDefault for the days the User works in the week
    case workDays = "settings.workDays"
    // UserDefault for the starting hour of each workday
    case startOfWorkDay = "settings.startOfWorkDay"
    // UserDefault for the ending hour of each workday
    case endOfWorkDay = "settings.endOfWorkDay"
    // UserDefault, if the DefaultValues have been set
    case didSetDefaultValues = "settings.didSetDefaultValues"
    
    case useThemedAppIcon = "settings.useThemedAppIcon"
    

    /// Function used to set the UserDefaults to standard values when the User starts the app for the first time.
    static func setDefaultValuesIfNeeded() {
        guard UserDefaults.standard.value(forKey: didSetDefaultValues.rawValue) as? Bool != true else { return }
        UserDefaults.standard.set(Worktime(hours: 8, minutes: 0).rawValue, forKey: startOfWorkDay.rawValue)
        UserDefaults.standard.set(Worktime(hours: 16, minutes: 0).rawValue, forKey: endOfWorkDay.rawValue)
        UserDefaults.standard.set(Set<Int>([1,2,3,4,5]).rawValue, forKey: workDays.rawValue)
        UserDefaults.standard.set(true, forKey: didSetDefaultValues.rawValue)
        UserDefaults.standard.set(false, forKey: useThemedAppIcon.rawValue)
    }
}

/// A View to get Advanced Settings. This is currently used to show the onboarding view again.
struct AdvancedSettings: View {
    // Setting the onboardingDone variable for the first time in the AppStorage
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

/// The View for the SettingsTab including the workday settings, the accentColor setting and the advanced settings
struct SettingsTab: View {
// Setting the accentColor variable for the first time in the AppStorage
    @AppStorage(SettingsAppStorageKey.accentColor.rawValue) private var accentColor: ColorChoice = .blue
    @AppStorage(SettingsAppStorageKey.useThemedAppIcon.rawValue) private var useThemedAppIcon: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                WorkDaysSettingsView()
                
                SimpleColorPicker(title: "color-accent", selection: $accentColor, allowCustomColor: false)
                Toggle("settings-use-themed-appicon", isOn: $useThemedAppIcon)
                
                Section {
                    NavigationLink("advanced-settings") {
                        AdvancedSettings()
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("settings"))
            .onChange(of: accentColor) { newValue in
                guard useThemedAppIcon else { return }
                UIApplication.shared.setAlternateIconName(newValue.appIconName)
            }
            .onChange(of: useThemedAppIcon) { newValue in
                let name = newValue ? accentColor.appIconName : nil
                UIApplication.shared.setAlternateIconName(name)
            }
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
