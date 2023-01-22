//
//  SwiftUIView.swift
//  teha
//
//  Created by Andreas Romann on 17.01.23.
//

import SwiftUI


struct OnboardingView: View {
    @AppStorage(SettingsAppStorageKey.onboardingDone.rawValue) private var onboardingDone: Bool = false
    @State private var currentTab = 0
    
    var hasMorePages: Bool {
        return currentTab < OnboardingPageData.list.count - 1
    }
    
    var body: some View {
        VStack {
            HStack {
                if currentTab > 0 {
                    Button("back") {
                        currentTab -= 1
                    }.padding()
                } else {
                    Button("skip") {
                        onboardingDone = true
                    }.padding()
                }
                Spacer()
                Button(hasMorePages ? "next" : "done") {
                    if hasMorePages {
                        currentTab += 1
                    } else {
                        onboardingDone = true
                    }
                }
                .padding()
                .fontWeight(.semibold)
            }
            
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
