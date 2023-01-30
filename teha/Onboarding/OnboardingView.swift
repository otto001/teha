//
//  SwiftUIView.swift
//  teha
//
//  Created by Andreas Romann on 17.01.23.
//

import SwiftUI

/// The View displaying all onboarding pages
struct OnboardingView: View {
    // Setting the onboardingDone variable for the first time in the AppStorage
    @AppStorage(SettingsAppStorageKey.onboardingDone.rawValue) private var onboardingDone: Bool = false
    // The currentTab of the onboarding as Int
    @State private var currentTab = 0

    // A variable that is true if the onboarding has more pages left
    var hasMorePages: Bool {
        return currentTab < OnboardingPageData.list.count - 1
    }

    // The View that displays all pages and also the interactive buttons
    var body: some View {
        VStack {
            HStack {
                // Create a button to go back one page or skip the entire onboaring
                if currentTab > 0 {
                    Button("back") {
                        currentTab -= 1
                    }.padding()
                } else {
                    Button("skip") {
                        // Set onboardingDone = true to get to the main page
                        onboardingDone = true
                    }.padding()
                }
                Spacer()
                // Create a button to go forward one page or domplete the oboarding process
                Button(hasMorePages ? "next" : "done") {
                    if hasMorePages {
                        currentTab += 1
                    } else {
                        // Set onboardingDone = true to get to the main page
                        onboardingDone = true
                    }
                }
                .padding()
                .fontWeight(.semibold)
            }

            // Create a tabView with a pageView for each onboarding page in the onboarding data
            TabView(selection: $currentTab) {
                ForEach(OnboardingPageData.list) { viewData in
                    OnboardingPageView(data: viewData)
                        .tag(viewData.id)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, -20)
            .animation(.default, value: currentTab)
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
