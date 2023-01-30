//
//  OnboardingPageView.swift
//  teha
//
//  Created by Andreas Romann on 17.01.23.
//

import SwiftUI

/// A Data struct to easily iterate over every oboarding page containing a text and an image
struct OnboardingPageData: Hashable, Identifiable {
    let id: Int
    let image: String
    let text: String
    
    static let list: [OnboardingPageData] = [
        .init(id: 0, image: "screenshot-tasks", text: String(localized: "onboarding-tasks")),
        .init(id: 1, image: "screenshot-projects", text: String(localized: "onboarding-projects")),
        .init(id: 2, image: "screenshot-suggestions", text: String(localized: "onboarding-suggestions"))
    ]
}

/// The view that displays an onboarding page
struct OnboardingPageView: View {
    var data: OnboardingPageData

    // Get the User set environment variables of language and color scheme
    @Environment(\.locale) var locale
    @Environment(\.colorScheme) var colorScheme

    // Create a string to the image file according to image name , color scheme and language
    var localizedImageKey: String {
        let colorSchemeCode = colorScheme == .dark ? "dark" : "light"
        let localeIdentifier = locale.identifier.isEmpty ? "en_GB" : locale.identifier
        let localeCode = localeIdentifier.substring(start: 0, end: 2)
        return "\(data.image)-\(colorSchemeCode)-\(localeCode)"
    }

    // A View displaying the image
    @ViewBuilder var image: some View {
        
        Image(localizedImageKey)
            .resizable()
            .scaledToFit()
            .mask {
                Rectangle().padding(.top, 28)
            }
            .padding(.top, -28)
            .cornerRadius(24)
            
    }

    // A View containing the displayed image and the text of the data object
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
            
            Text(data.text)
                .font(.headline)
                .bold()
                .padding(.top, 10)
            
            Spacer(minLength: 20)
        }
        .frame(maxHeight: .infinity)
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView(data: OnboardingPageData.list.first!)
    }
}
