//
//  OnboardingPageView.swift
//  teha
//
//  Created by Andreas Romann on 17.01.23.
//

import SwiftUI

struct OnboardingPageData: Hashable, Identifiable {
    let id: Int
    let image: String
    let text: String
    
    static let list: [OnboardingPageData] = [
        .init(id: 0, image: "screenshot-tasks", text: String(localized: "onboarding-tasks")),
        .init(id: 1, image: "screenshot-projects", text: String(localized: "onboarding-projects"))
    ]
}

struct OnboardingPageView: View {
    var data: OnboardingPageData
    
    @Environment(\.locale) var locale
    @Environment(\.colorScheme) var colorScheme
    
    var localizedImageKey: String {
        let colorSchemeCode = colorScheme == .dark ? "dark" : "light"
        let localeIdentifier = locale.identifier.isEmpty ? "en_GB" : locale.identifier
        let localeCode = localeIdentifier.substring(start: 0, end: 2)
        return "\(data.image)-\(colorSchemeCode)-\(localeCode)"
    }
    
    @ViewBuilder var image: some View {
        
        Image(localizedImageKey)
            .resizable()
            .scaledToFit()
            .cornerRadius(24)
    }
    
    var body: some View {
        VStack(spacing: 20){
            
            if colorScheme == .dark {
                image
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(lineWidth: 1)
                            .opacity(0.2)
                    }
            } else {
                image
                    .shadow(radius: 6)
            }
            
 
            Spacer()
            
            Text(data.text)
                .font(.title)
                .bold()
            
            Spacer()
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView(data: OnboardingPageData.list.first!)
    }
}
