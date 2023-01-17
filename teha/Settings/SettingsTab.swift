//
//  SettingsView.swift
//  teha
//
//  Created by Second Dude on 10.01.23.
//

import SwiftUI

enum SettingsAppStorageKey: String {
    case accentColor = "settings.accentColor"
    case onboardingdone = "settings.onboardingdone"
}

struct SettingsTab: View {
    @AppStorage(SettingsAppStorageKey.accentColor.rawValue) private var accentColor: ColorChoice = .blue
    
    var body: some View {
        RoutedNavigation { router in
            Form {
                SimpleColorPicker(title: String(localized: "color-accent"), color: $accentColor)
            }
            .registerSimpleColorPicker {
                router.pop()
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
